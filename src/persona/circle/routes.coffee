"use strict"

###*
{@link module:joukou-api/persona/circle/Model|Circle} APIs provide information
about the available Circles. In future the ability to create, sell and buy
Circles will be added.

@module joukou-api/persona/circle/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
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
