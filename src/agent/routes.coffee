"use strict"

###*
{@link module:joukou-api/agent/Model|Agent} routes.

@module joukou-api/agent/routes
@requires lodash
@requires jsonwebtoken
@requires joukou-api/config
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

_             = require( 'lodash' )
jwt           = require( 'jsonwebtoken' )
authn         = require( '../authn' )
authz         = require( '../authz' )
config        = require( '../config' )
AgentModel    = require( './Model' )
{ UnauthorizedError } = require( 'restify' )

module.exports = self =
  ###*
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(  '/agent', authn.authenticate, self.index )
    server.post( '/agent', self.create )
    server.post( '/agent/authenticate', authn.authenticate, self.authenticate )
    server.get(  '/agent/:agentKey', authn.authenticate, self.retrieve )

  index: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to create an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  create: ( req, res, next ) ->
    AgentModel.create( req.body ).then( ( agent ) ->
      agent.save()
    )
    .then( ( agent ) ->
      self = "/agent/#{agent.getKey()}"
      res.header( 'Location', self )
      res.link( self, 'joukou:agent' )
      res.send( 201, {} )
    )
    .fail( ( err ) -> res.send( err ) )

  ###*
  Handles a request to authenticate an agent, and respond with a JSON Web Token
  if successful.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  authenticate: ( req, res, next ) ->
    # TODO config.jwt.secret
    token = jwt.sign( req.user, 'abc', expiresInMinutes: 60 * 5 )
    res.link( "/agent/#{req.user.getKey()}", 'joukou:agent' )
    res.link( '/persona', 'joukou:personas', title: 'List of Personas that this Agent has access to' )
    res.send( 200, token: token )

  ###*
  Handles a request to retrieve details about an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  retrieve: ( req, res, next ) ->
    AgentModel.retrieve( req.params.agentKey ).then( ( agent ) ->
      unless agent.getEmail() is req.user.getEmail() or
      req.user.hasRole( 'operator' )
        next( new UnauthorizedError() )
        return

      res.link( '/persona', 'joukou:personas', title: 'List of Personas that this Agent has access to' )
      res.send( 200, agent.getRepresentation() )
    ).fail( ( err ) ->
      if err.notFound
        # Technically this should be a 404 NotFound, but that could be abused by
        # an attacker to discover valid user keys.
        res.send( 401 )
      else
        res.send( 503 )
    )
