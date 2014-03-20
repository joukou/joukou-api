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
{@link module:joukou-api/agent/Model|Agent} routes.

@module joukou-api/agent/routes
@requires lodash
@requires jsonwebtoken
@requires joukou-api/config
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
###

_             = require( 'lodash' )
jwt           = require( 'jsonwebtoken' )
authn         = require( '../authn' )
authz         = require( '../authz' )
config        = require( '../config' )
AgentModel    = require( './model' )
{ UnauthorizedError, NotFoundError } = require( 'restify' )
env           = require( '../env' )
passport      = require( 'passport' )
githubEnv     = env.getGithubAuth()
graph_routes  = require( './graph/routes' )

module.exports = self =
  ###*
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.del(  '/agent', authn.authenticate, self.delete )
    server.get(  '/agent', authn.authenticate, self.index )
    server.post( '/agent', self.create )
    # Post should be handled a different way
    # It should really only be a get
    server.get( '/agent/authenticate/github', authn.Github.authenticate, self.authenticate )
    server.get( '/agent/authenticate', authn.Github.authenticate, self.authenticate )
    # server.post(  '/agent/authenticate', authn.authenticateOAuth, self.authenticate )
    server.get(  '/agent/authenticate/callback', authn.Github.authenticate, self.callback )
    server.get(  '/agent/authenticate/failed', self.failed )
    server.get(  '/agent/:agentKey', authn.authenticate, self.retrieve )
    graph_routes.registerRoutes( server )
  
  delete: ( req, res, next ) ->
    if not req.user
      res.send(503)
      return
    req.user.delete().then(->
      res.send(204)
    ).fail( next )
  
  failed: ( req, res ) ->
    # res.header("Location", githubEnv.failedUrl )
    res.send(503)
  
  callback: (req, res, val ) ->
    token = null
    if req and req.user
      token = authn.Bearer.generate(req.user)
    if token
      res.header("Location", githubEnv.successUrl + "/" + token)
    else
      res.header("Location", githubEnv.failedUrl )

    res.send(302)

  index: ( req, res, next ) ->
    res.send( 200, req.user.getValue() )

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
    token = authn.Bearer.generate(req.user)
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
