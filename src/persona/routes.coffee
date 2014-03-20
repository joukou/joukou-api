"use strict"

###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

###*
{@link module:joukou-api/personas/Model|Persona} routes.

@module joukou-api/persona/routes
@requires lodash
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/persona/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
###

_              = require( 'lodash' )
async          = require( 'async' )
authn          = require( '../authn' )
authz          = require( '../authz' )
hal            = require( '../hal' )
request        = require( 'request' )
circle_routes  = require( './circle/routes' )
graph_routes   = require( './graph/routes' )
robot_routes   = require( './robot/routes' )
PersonaModel   = require( './model' )
PersonaCreator = require( '../authn/creators/persona' )

module.exports = self =

  ###*
  Register `/persona` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(  '/persona', authn.authenticate, self.index )
    server.post( '/persona', authn.authenticate, self.create )
    server.get(  '/persona/:key', authn.authenticate, self.retrieve )
    circle_routes.registerRoutes( server )
    graph_routes.registerRoutes( server )
    robot_routes.registerRoutes( server )
    return

  ###
  @api {get} /persona List of Personas that you have access to
  @apiName PersonaIndex
  @apiGroup Persona
  ###
  index: ( req, res, next ) ->
    request(
      uri: 'http://localhost:8098/mapred'
      method: 'POST'
      json:
        inputs:
          module: 'yokozuna'
          function: 'mapred_search'
          arg: [ 'persona', 'agents.key:' + req.user.getKey() ]
        query: [
          {
            map:
              language: 'javascript'
              keep: true
              source: ( ( value, keyData, arg ) ->
                result = Riak.mapValuesJson( value )[ 0 ]
                result.key = value.key
                return [ result ]
                #[ [ value.bucket, value.key, Riak.mapValuesJson( value )[ 0 ] ] ]
                #[ [ value.bucket_type, value.bucket, value.key, Riak.mapValuesJson( value )[ 0 ] ] ]
              ).toString()
          }
        ]
    , ( err, reply ) ->
      if err
        res.send( 503 )
        return

      representation = {}
      representation._embedded = _.reduce( reply.body, ( memo, persona ) ->
        memo[ 'joukou:persona' ].push(
          name: persona.name
          key: persona.key
          _links:
            self:
              href: "/persona/#{persona.key}"
            'joukou:agent': _.map( persona.agents, ( agent ) ->
              href: "/agent/#{agent.key}"
              name: agent.role
            )
            'joukou:circles':
              href: "/persona/#{persona.key}/circle"
              title: 'List of Circles available to this Persona'
        )
        memo
      , { 'joukou:persona': [] } )

      res.link( '/persona', 'joukou:persona-create', title: 'Create a Persona')

      res.send( 200, representation )
    )
    return

  ###
  @api {post} /persona Create a Joukou Persona
  @apiName CreatePersona
  @apiGroup Persona

  @apiParam {String} name The name of the Persona; e.g. the company name.
  @apiParam {Object.<String,Array>} _links Contains links to other resources.

  @apiExample CURL Example:
    curl -i -X POST https://api.joukou.com/persona \
      -H 'Authorization: Basic aXNhYWMuam9obnN0b25Aam91a291LmNvbTpwYXNzd29yZA=='
      -H 'Content-Type: application/json' \
      --data-binary @persona.json

  @apiExample persona.json
    {
      "name": "Joukou Ltd",
      "_links": {
        "curies": [
          {
            "name": "joukou",
            "href": "https://rels.joukou.com/{rel}",
            "templated": true
          }
        ],
        "joukou:agent": [
          {
            "href": "/agent/8a549b6d-70c9-40b1-a482-d11e36b780b3",
            "role": "admin"
          }
        ]
      }
    }

  @apiSuccess (201) Created The Persona has been created successfully.
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure creating the Persona, the client should try again later.
  ###

  ###*
  Handles a request to create a new *persona*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  create: ( req, res, next ) ->
    data = {}
    data.name = req.body.name
    data.agents = []

    try
      document = hal.parse( req.body,
        links:
          'joukou:agent':
            match: '/agent/:key'
            name:
              required: false
              type: 'enum'
              values: [ 'admin' ]
      )
      if document.links[ 'joukou:agent' ]
        for agent in document.links[ 'joukou:agent' ]
          data.agents.push(
            key: agent.key
            role: agent.name
          )
    catch err
      next( err )
      return

    data.agents.push(
      key: req.user.getKey()
      role: 'creator'
    )

    PersonaCreator.create(
      data.name
      data.agents
    )
    .then( ( persona ) ->
      persona.save()
    )
    .then( ( persona ) ->
      self = "/persona/#{persona.getKey()}"
      res.link( self, 'joukou:persona' )
      res.header( 'Location', self )
      res.send( 201, {} )
    )
    .fail( ( err ) -> next( err ) )
    return

  ###
  @api {get} /persona/:personaKey Retrieve a Joukou Persona
  @apiName RetrievePersona
  @apiGroup Persona
  ###

  ###*
  Handles a request to retrieve a certain *persona's* details.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  retrieve: ( req, res, next ) ->
    authz.hasPersona(req.user, req.params.key)
    .then( ( persona ) ->
      for agent in persona.getValue().agents
        res.link( "/agent/#{agent.key}", 'joukou:agent', name: agent.role )
        res.link( "/persona/#{persona.getKey()}/graph", 'joukou:graphs', title: "List of Graphs owned by this Persona" )
        res.link( "/persona/#{persona.getKey()}/graph", 'joukou:graph-create', title: "Create a Graph owned by this Persona" )
        res.link( "/persona/#{persona.getKey()}/circle", 'joukou:circles', title: 'List of Circles available to this Persona' )
      res.send( 200, _.pick( persona.getValue(), [ 'name' ] ) )
    ).fail( ( err ) ->
      next( err )
    )
