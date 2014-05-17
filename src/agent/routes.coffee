"use strict"

###*
{@link module:joukou-api/agent/model|Agent} routes.

@module joukou-api/agent/routes
@requires lodash
@requires jsonwebtoken
@requires joukou-api/config
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/agent/model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

_       = require( 'lodash' )
jwt     = require( 'jsonwebtoken' )
authn   = require( '../authn' )
authz   = require( '../authz' )
model   = require( './model' )
config  = require( '../config' )

module.exports = self =
  ###*
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.post( '/agent', self.create )
    server.post( '/agent/authenticate', authn.authenticate, self.authenticate )
    server.get(  '/agent/:username', authn.authenticate, self.show )
    server.post( '/agent/:username/persona', authn.authenticate,
      self.linkToPersonas )
    server.get(  '/agent/:username/persona', authn.authenticate,
      self.linkedPersonasSearch )
    server.get(  '/agent/:username/personas/facets', authn.authenticate,
      self.linkedPersonasSearchFacets )

  ###*
  Handles a request to create an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  create: ( req, res, next ) ->
    model.create( req.body ).save().then( ->
      res.send( 201 )
    ).fail( ( err ) ->
      res.send( err )
    )

  ###*
  Handles a request to authenticate an agent, and respond with a JSON Web Token
  if successful.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  authenticate: ( req, res, next ) ->
    token = jwt.sign( req.user, config.jwt.secret, expiresInMinutes: 60 * 5 )
    res.send( 200, token: token )

  ###*
  Handles a request to retrieve details about an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  show: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to create a relationship between an agent and a persona.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkToPersonas: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to search for relationships between an agent and personas.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearch: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to retrieve facets for a search for relationships between
  an agent and personas.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearchFacets: ( req, res, next ) ->
    res.send( 503 )
