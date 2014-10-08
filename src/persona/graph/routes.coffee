"use strict"

###*
{@link module:joukou-api/persona/graph/model|Graph} APIs provide information about the
graphs that an agent has authorization to access.

@module joukou-api/persona/graph/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

_             = require( 'lodash' )
uuid          = require( 'node-uuid' )
async         = require( 'async' )
authn         = require( '../../authn' )
hal           = require( '../../hal' )
request       = require( 'request' )
connection_routes = require( './connection/routes' )
process_routes = require( './process/routes' )
network_routes = require( './network/routes' )
GraphModel    = require( './Model' )
PersonaModel  = require( '../Model')
{ UnauthorizedError, ForbiddenError, NotFoundError } = require( 'restify' )

module.exports = self =

  ###*
  Registers graph-related routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(  '/persona/:personaKey/graph', authn.authenticate, self.index )
    server.post( '/persona/:personaKey/graph', authn.authenticate, self.create )
    server.get(  '/persona/:personaKey/graph/:graphKey', authn.authenticate, self.retrieve )
    connection_routes.registerRoutes( server )
    process_routes.registerRoutes( server )
    network_routes.registerRoutes( server )
    return

  ###*
  Handles a request to search for graphs owned by a certain persona.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  index: ( req, res, next ) ->
    request(
      uri: 'http://localhost:8098/mapred'
      method: 'POST'
      json:
        inputs:
          module: 'yokozuna'
          function: 'mapred_search'
          arg: [ 'graph', 'personas.key:' + req.params.personaKey ]
        query: [
          {
            map:
              language: 'javascript'
              keep: true
              source: ( ( value, keyData, arg ) ->
                result = Riak.mapValuesJson( value )[ 0 ]
                result.key = value.key
                return [ result ]
              ).toString()
          }
        ]
    , ( err, reply ) ->
      if err
        res.send( 503 )
        return

      representation = {}
      representation._embedded = _.reduce( reply.body, ( memo, graph ) ->
        memo[ 'joukou:graph' ].push(
          _links:
            self:
              href: "/persona/#{req.params.personaKey}/graph/#{graph.key}"
            'joukou:persona':
              href: "/persona/#{req.params.personaKey}"
            'joukou:process-create':
              href: "/persona/#{req.params.personaKey}/graph/#{graph.key}/process"
            'joukou:processes':
              href: "/persona/#{req.params.personaKey}/graph/#{graph.key}/process"
            'joukou:connection-create':
              href: "/persona/#{req.params.personaKey}/graph/#{graph.key}/connection"
            'joukou:connections':
              href: "/persona/#{req.params.personaKey}/graph/#{graph.key}/connection"
        )
        memo
      , { 'joukou:graph': [] } )

      res.link( "/persona/#{req.params.personaKey}", 'joukou:persona' )

      res.send( 200, representation )
      return
    )
    return

  ###
  @api {post} /persona/:personaKey/graph Creates a Joukou graph
  @apiName CreateGraph
  @apiGroup Graph

  @apiParam {Object} properties

  @apiExample CURL Example:
    curl -i -X POST https://api.joukou.com/persona/7bcb937e-3938-49c5-a1ce-5eb45f194f2f/graph \
      -H 'Content-Type: application/json' \
      -d '{ "name": "CRM to Sharepoint Integration" }'
  
  @apiSuccess (201) Created The graph has been created successfully.

  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure creating the graph, the client should try again later.
  ###

  create: ( req, res, next ) ->
    PersonaModel.retrieve( req.params.personaKey ).then( ( persona ) ->
      data = {}
      data.name = req.body.name
      data.personas = [
        key: persona.getKey()
      ]

      GraphModel.create( data ).then( ( graph ) ->
        graph.save()
      )
      .then( ( graph ) ->
        self = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}"
        res.link( self, 'joukou:graph' )
        res.header( 'Location', self )
        res.send( 201, {} )
      )
      .fail( ( err ) -> next( err ) )
    )

  ###
  @api {get} /graph/:graphKey Retrieve the definition of a Joukou graph
  @apiName RetrieveGraph
  @apiGroup Graph

  @apiExample CURL Example:
    curl -i -X GET https://api.joukou.com/graph/15269bc7-a6b2-42c5-8805-879f1fe11ec0

  @apiSuccess (200) OK The graph definition is sent in the response.

  @apiError (401) Unauthorized The request requires user authentication, or authorization has been refused for the supplied credentials.
  @apiError (404) NotFound The server did not find a graph definition that matched the provided key.
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure retrieving the graph definition, the client should try again later.
  ###
  retrieve: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        for item in graph.getValue().personas
          res.link( "/persona/#{item.key}", 'joukou:persona' )

        res.link( "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process", 'joukou:process-create', title: 'Add a Process to this Graph' )
        res.link( "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process", 'joukou:processes', title: 'List of Processes for this Graph' )
        res.link( "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/connection", 'joukou:connection-create', title: 'Add a Connection to this Graph' )
        res.link( "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/connection", 'joukou:connections', title: 'List of Connections for this Graph' )

        representation = _.pick( graph.getValue(), [ 'name' ] )
        representation._embedded =
          'joukou:process': _.reduce( graph.getValue().processes or {}, ( memo, process, processKey ) ->
            memo.push(
              _links:
                self:
                  href: "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{processKey}"
                #'joukou:circle': TODO
                #  href: "/persona/#{persona.getKey()}/circle/#{process.circle.key}"
              metadata: process.metadata
            )
            memo
          , [] )
          'joukou:connection': _.reduce( graph.getValue().connections or [], ( memo, connection, i ) ->
            memo.push(
              _links:
                self:
                  href: "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/connection/#{connection.key}"
                'joukou:process': [
                  {
                    name: 'src' # TODO href
                  }
                  {
                    name: 'tgt' # TODO href
                  }
                ]
            )
            memo
          , [] )


        res.send( 200, representation )
        return
      )
    )
    .fail( ( err ) -> next( err ) )
    return