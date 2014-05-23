"use strict"

###*
{@link module:joukou-api/personas/model|Persona} APIs.

@module joukou-api/persona/routes
@requires lodash
@requires joukou-api/authn
@requires joukou-api/authz
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

self  = module.exports
_     = require( 'lodash' )
authn = require( '../authn' )
authz = require( '../authz' )

module.exports = self =

  ###*
  Register `/persona` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.post( '/persona', authn.authenticate, self.create )
    server.get(  '/persona/:personaKey', authn.authenticate, self.show )
  
    return

  ###*
  Handles a request to create a new *persona*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  create: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to retrieve a certain *persona's* details.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  show: ( req, res, next ) ->
    res.send( 503 )


