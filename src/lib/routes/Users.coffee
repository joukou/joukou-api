"use strict"

###*
@class joukou-api.routes.Users
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Brabant <ben.brabant@joukou.co>
@author Sebastian Berlein <sebastian.berlein@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.

A user is an agent.

An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.
###

jwt = require( 'jsonwebtoken' )


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
  @property {joukou-api.AuthN} AuthN
  ###
  AuthN = require( '../AuthN' )

  ###*
  @private
  @static
  @property {joukou-api.AuthZ} AuthZ
  ###
  AuthZ = require( '../AuthZ' )

  ###*
  @private
  @static
  @property {joukou-api.model.User} Model
  ###
  UserModel = require( '../model/User' )

  ###*
  @method registerRoutes
  @param {joukou-api.server} server
  ###
  registerRoutes: ( server ) ->
    server.post( '/users', _.bind( @create, @ ) )
    
    server.post( '/authenticate', AuthN.authenticate,
      _.bind( @authenticate, @ ) )
    
    server.get(  '/users/:username', AuthN.authenticate, _.bind( @show, @ ) )

    server.post(
      '/users/:username/personas',
      AuthN.authenticate,
      _.bind( @linkToPersonas, @ )
    )
    
    server.get(
      '/users/:username/personas',
      AuthN.authenticate,
      _.bind( @linkedPersonasSearch, @ )
    )

    server.get(
      '/users/:username/personas/facets',
      AuthN.authenticate,
      _.bind( @linkedPersonasSearchFacets, @ )
    )

  ###*
  @method create
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  create: ( req, res, next ) ->
    UserModel.create( req.body ).save().then( ->
      res.send( 201 )
    ).fail( ( err ) ->
      res.send( err )
    )

  ###*
  @method authenticate
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  authenticate: ( req, res, next ) ->
    token = jwt.sign( req.user, 'abc', expiresInMinutes: 60 * 5 )
    # TODO get secret from config.yaml
    res.send( 200, token: token )

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
