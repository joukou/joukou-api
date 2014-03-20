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

CircleModel  = require( './model' )
PersonaModel = require( '../persona/model' )
_            = require( 'lodash' )
Q            = require( 'q' )
authn        = require( '../authn' )
authz        = require( '../authz' )

module.exports = self =

  registerRoutes: ( server ) ->
    server.get( '/circle', authn.authenticate, self.index )
    server.get( '/circle/:key', authn.authenticate, self.retrieve )
    server.del( '/circle/:key', authn.authenticate, self.remove )
    server.put( '/circle/', authn.authenticate, self.create )
    server.get( '/circle/search/:name', authn.authenticate, self.search )
    return

  index: ( req, res, next ) ->

  retrieve: ( req, res, next ) ->
    authz.hasCircle( req.user, req.params.key )
    .then( ( circle ) ->
      # TODO filter keys
      res.send( 200, circle.getValue() )
    )
    .fail( next )

  remove: ( req, res, next ) ->
    authz.hasCircle( req.user, req.params.key )
    .then( ( circle ) ->

    )
    .fail( next )
  create: ( req, res, next ) ->

  search: ( req, res, next ) ->
    PersonaModel.getForAgent(req.user)
    .then((personas) ->
      promises = _.map(personas, (persona) ->
        like = CircleModel.likeQuery("name", req.params.name, "AND")
        CircleModel.search(
          """
          personas.key:#{persona.getKey()} AND
          #{like}
          """
        ).then((result) ->
          return {
            persona: persona,
            result: result
          }
        )
      )
      Q.all(
        promises
      )
      .then((results) ->
        representation = {}
        representation.result = _.map(_.flatten(results, true), (result) ->
          return {
            persona: result.persona
            result: _.map(result.result, (circle) ->
              value = circle.getValue()
              value.key = circle.getKey()
              return value
            )
          }

        )
        if req.accepts("application/hal+json")
          circles = _.map(representation.result, (result) ->
            persona = result.persona
            return _.map(result.result, (circle) ->
              circle = _.cloneDeep(circle)
              circle._links =
                self:
                  href: "/persona/#{persona.getKey()}/circle/#{circle.key}"
                'joukou:persona':
                  href: "/persona/#{persona.getKey()}"
              return circle
            )
          )
          representation["_embedded"] = {
            "joukou:circle": _.flatten(circles, true)
          }
        representation.result = _.map(representation.result, (result) ->
          return result.result
        )
        representation.result = _.flatten(representation.result, true)

        res.send(200, representation)
      )
    )
    .fail( ->
      res.send(200, {result:
        []})
    )



