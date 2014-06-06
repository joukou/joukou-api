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

module.exports = self =
  ###*
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.post('/agent', self.create )
    server.post('/agent/authenticate', authn.authenticate, self.authenticate )
    server.get( '/agent/:email', authn.authenticate, self.show )
    server.post('/agent/:email/persona', authn.authenticate, self.addPersona )
    server.get( '/agent/:email/persona', authn.authenticate, self.personaSearch)
    server.get( '/agent/:email/persona/facet', authn.authenticate,
      self.personaSearchFacets )

  ###*
  Handles a request to create an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  create: ( req, res, next ) ->
    AgentModel.create( req.body ).then( ( agent ) ->
      agent.save().then( ( reply ) ->
        res.send( 201 )
      ).fail( ( err ) ->
        res.send( 503 )
      )
    ).fail( ( err ) ->
      res.send( 503 )
    )


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
    unless req.params.username is req.user.getUsername() or
    req.user.hasRole( 'operator' )
      res.send( 401 )
    else
      AgentModel.retrieveByEmail( req.params.username ).then( ( agent ) ->
        res.send( 200, agent.getRepresentation() )
      ).fail( ( err ) ->
        if err.notFound
          # Technically this should be a 404 NotFound, but that can be abused by
          # an attacker to discover valid vs invalid usernames.
          res.send( 401 )
        else
          res.send( 503 )
      )

  ###*
  Handles a request to create a relationship between an agent and a persona.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  addPersona: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to search for relationships between an agent and personas.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  personaSearch: ( req, res, next ) ->
    res.send( 503 )

  ###*
  Handles a request to retrieve facets for a search for relationships between
  an agent and personas.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  personaSearchFacets: ( req, res, next ) ->
    res.send( 503 )
