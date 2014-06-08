"use strict"

###*
{@link module:joukou-api/personas/Model|Persona} routes.

@module joukou-api/persona/routes
@requires lodash
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/persona/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

_             = require( 'lodash' )
authn         = require( '../authn' )
authz         = require( '../authz' )
PersonaModel  = require( './Model' )

module.exports = self =

  ###*
  Register `/persona` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.post( '/persona', authn.authenticate, self.create )
    server.get(  '/persona/:key', authn.authenticate, self.retrieve )
  
    return

  ###*
  Handles a request to create a new *persona*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  create: ( req, res, next ) ->
    #console.log(require('util').inspect(req.body))
    PersonaModel.create( req.body ).then( ( persona ) ->
      persona.save().then( ( reply ) ->
        self = "/persona/#{persona.getKey()}"
        res.header( 'Location', self )
        res.link( self, 'location' ) # TODO rel uri
        res.send( 201 )
      ).fail( ( err ) ->
        res.send( 503 )
      )
    ).fail( ( err ) ->
      res.send( 503 )
    )

  ###*
  Handles a request to retrieve a certain *persona's* details.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  retrieve: ( req, res, next ) ->
    PersonaModel.retrieve( req.params.key ).then( ( persona ) ->
      res.send( 200, persona.getValue() )
    ).fail( ( err ) ->
      if err.notFound
        res.send( 404 )
      else
        res.send( 503 )
    )