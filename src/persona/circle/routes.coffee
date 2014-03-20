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
{@link module:joukou-api/persona/circle/Model|Circle} APIs provide information
about the available Circles. In future the ability to create, sell and buy
Circles will be added.

@module joukou-api/persona/circle/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
###
CircleModel  = require( '../../circle/model' )
_            = require( 'lodash' )
CircleRoutes = require( '../../circle/routes' )
authz        = require( '../../authz' )
authn        = require( '../../authn' )

module.exports = self =

  registerRoutes: ( server ) ->
    server.get( '/persona/:personaKey/circle', authn.authenticate, self.index )
    server.get( '/persona/:personaKey/circle/:key', authn.authenticate, self.retrieve )
    return

  retrieve: (req, res, next) ->
    authz.hasPersona(req.user, req.params.personaKey)
    .then( ( persona ) ->
      CircleRoutes.retrieve(req, res, next)
    )
    .fail(next)

  index: ( req, res, next ) ->
    authz.hasPersona(req.user, req.params.personaKey)
    .then( ( persona ) ->
      CircleModel.retrieveByPersona(req.params.personaKey)
      .then((circles) ->
        representation = {}
        if req.accepts('application/hal+json')
          representation["_embedded"] = {
            "joukou:circle": _.map(circles, (circle) ->
              value = circle.getValue()
              value.key = circle.getKey()
              value._links =
                self:
                  href: "/persona/#{req.params.personaKey}/circle/#{circle.getKey()}"
                'joukou:persona':
                  href: "/persona/#{req.params.personaKey}"
              return value
            )
          }
        else
          representation.circles = _.map(circles, (circle) ->
            return circle.getValue()
          )
        res.send(200, representation)
      )
    )
    .fail(next)
