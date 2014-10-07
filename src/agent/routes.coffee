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
{ UnauthorizedError, NotFoundError } = require( 'restify' )
env           = require( '../env' )
passport      = require('passport')
githubEnv     = env.getGithubAuth()

module.exports = self =
  ###*
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(  '/agent', authn.authenticate, self.index )
    server.post( '/agent', self.create )
    # Post should be handled a different way
    # It should really only be a get
    server.get( '/agent/authenticate', authn.authenticateOAuth, self.authenticate )
    # server.post(  '/agent/authenticate', authn.authenticateOAuth, self.authenticate )
    server.get(  '/agent/authenticate/callback', authn.authenticateOAuth, self.callback )
    server.get(  '/agent/authenticate/failed', self.failed )
    server.get(  '/agent/:agentKey', authn.authenticate, self.retrieve )

  failed: ( req, res ) ->
    res.header("Location", githubEnv.failedUrl )
    res.send(302)
  callback: (req, res, val ) ->
    token = null
    if req and req.user
      token = authn.generateTokenFromAgent(req.user)
    if token
      res.header("Location", githubEnv.successUrl + "/" + token)
    else
      res.header("Location", githubEnv.failedUrl )

    res.send(302)

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
    token = authn.generateTokenFromAgent(req.user)
    res.link( "/agent/#{req.user.getKey()}", 'joukou:agent' )
    res.link( '/persona', 'joukou:personas', title: 'List of Personas' )
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

      res.link( '/persona', 'joukou:personas', title: 'List of Personas' )
      res.send( 200, agent.getRepresentation() )
    ).fail( ( err ) ->
      if err instanceof NotFoundError
        # Technically this should be a 404 NotFound, but that could be abused by
        # an attacker to discover valid user keys.
        res.send( 401 )
      else
        next( err )
    )
