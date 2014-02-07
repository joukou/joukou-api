"use strict"
###*
@class joukou-server.routes.Agents
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Braband <ben.brabant@joukou.co>
@author Sebastian Berlein <sebastian.berlein@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.

An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.
###

module.exports = self = new class
  ###*
  @private
  @static
  @property {lodash} _
  ###
  _     = require( 'lodash' )

  ###*
  @private
  @static
  @property {joukou-server.AuthN} AuthN
  ###
  AuthN = require( '../AuthN' )

  ###*
  @private
  @static
  @property {joukou-server.AuthZ} AuthZ
  ###
  AuthZ = require( '../AuthZ' )

  ###*
  @method registerRoutes
  @param {joukou-server.server} server
  ###
  registerRoutes: ( server ) ->
    server.post( '/agents', _.bind( @create, @ ) )
    server.post( '/agents/authenticate', AuthN.authenticate, _.bind( @authenticate, @ ) )
    server.get(  '/agents/:agentKey', AuthN.authenticate, _.bind( @show, @ ) )
    server.post( '/agents/:agentKey/personas', AuthN.authenticate, _.bind( @linkToPersonas, @ ) )
    server.get(  '/agents/:agentKey/personas', AuthN.authenticate, _.bind( @linkedPersonasSearch, @ ) )
    server.get(  '/agents/:agentKey/personas/facets', AuthN.authenticate, _.bind( @linkedPersonasSearchFacets, @ ) )

  ###*
  @method create
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  create: ( req, res, next ) ->

  ###*
  @method authenticate
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  authenticate: ( req, res, next ) ->

  ###*
  @method show
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  show: ( req, res, next ) ->

  ###*
  @method linkToPersonas
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkToPersonas: ( req, res, next ) ->

  ###*
  @method linkedPersonasSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearch: ( req, res, next ) ->

  ###*
  @method linkedPersonasSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearchFacets: ( req, res, next ) ->
