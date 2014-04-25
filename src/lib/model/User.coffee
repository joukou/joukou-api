"use strict"

###*
@class joukou-api.model.User
@extends joukou-api.model.Abstract
@requires joukou-api.schema.User
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

Abstract = require( './Abstract' )

module.exports = class extends Abstract

  ###*
  @private
  @static
  @property {joukou-api.model.User} self
  ###
  self = @

  ###*
  @private
  @static
  @property {lodash} _
  ###
  _ = require( 'lodash' )

  ###*
  @private
  @static
  @property {q} Q
  ###
  Q = require( 'q' )

  ###*
  @private
  @static
  @property {bcrypt} bcrypt
  ###
  bcrypt = require( 'bcrypt' )

  ###*
  @private
  @static
  @property {joukou-api.error.BcryptError} BcryptError
  ###
  BcryptError = require( '../error/BcryptError' )

  ###*
  @private
  @static
  @property {joukou-api.riakpbc.client} riakpbc
  ###
  riakpbc = require( '../riakpbc/client' )

  ###*
  @private
  @static
  @property {joukou-api.error.RiakError} RiakError
  ###
  RiakError = require( '../error/RiakError' )

  ###*
  @private
  @static
  @property {joukou-api.schema.User} schema
  ###
  schema = require( '../schema/User' )

  DuplicateError = require( '../error/DuplicateError' )

  @create = ( rawData ) ->
    new self( rawData: rawData )

  @load = ( username ) ->
    Abstract.load( 'users', username, self )

  ###*
  @method constructor
  @inheritdocs
  ###
  constructor: ( options ) ->
    _.assign( options,
      schema: schema
    )

  verifyPassword: ( password ) ->
    deferred = Q.defer()

    bcrypt.compare( password, @data.password, ( err, authenticated ) ->
      if err
        deferred.reject( new BcryptError( err ) )
      else
        deferred.resolve( authenticated )
    )

    deferred.promise

  save: ->
    deferred = Q.defer()

    @exists( @data.username ).then( ( exists ) ->
      if exists
        deferred.reject( new DuplicateError( 'username' ) )
      else
        riakpbc.put(
          bucket: @bucket
          key: @data.username
          content: @data
        , ( err, reply ) ->
          if err
            deferred.reject( err )
          else
            deferred.resolve()
        )
    )

    deferred.promise
