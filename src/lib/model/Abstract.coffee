"use strict"

###*
@class joukou-api.model.Abstract
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.

An abstract base class for models that are persisted to Basho Riak.
###

{ EventEmitter } = require( 'events' )

module.exports = class extends EventEmitter

  ###*
  @private
  @static
  @property {joukou-api.model.Abstract} self
  ###
  self = @

  ###*
  @private
  @static
  @property {q} Q
  ###
  Q = require( 'q' )

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

  { NotFoundError } = require( 'restify' )

  ###*
  @protected
  @static
  @method load
  @param {String} bucket
  @param {String} key
  @param {joukou-api.model.Abstract} model
  @return {q.promise}
  ###
  @load = ( bucket, key, model ) ->
    deferred = Q.defer()

    riakpbc.get( bucket: bucket, key: key, ( err, reply ) ->
      if err
        if err.notFound
          deferred.reject( new NotFoundError( err ) )
        else
          deferred.reject( new RiakError( err ) )
      else
        new model( reply.content )
    )

    deferred.promise

  ###*
  @method constructor
  @cfg options
  @cfg {schemajs.Schema} options.schema
  @cfg {Object} options.rawData The raw data
  @cfg {Object} options.bucket The Basho Riak bucket name that instances of this
                               model are persisted to.
  ###
  constructor: ( options ) ->
    @setSchema( options.schema )
    @setRawData( options.rawData )
    @bucket = options.bucket

  ###*
  @method setRawData
  @param {Object} rawData
  ###
  setRawData: ( @rawData ) ->
    { @valid, @data, @errors } = @schema.validate( @rawData )
    @emit( 'rawData', @rawData, @ )
    @emit( 'data', @data, @ )
    @emit( 'errors', @errors, @ ) unless @valid
    @

  ###*
  @method getData
  @return {Object} Filtered version of the raw data.
  ###
  getData: ->
    @data

  ###*
  @method setSchema
  @param {schemajs.Schema} options.schema
  ###
  setSchema: ( @schema ) ->
    @emit( 'schema', @schema, @ )
    @

  ###*
  @method isValid
  @returns {Boolean} `true` if raw data matched the schema, otherwise `false`.
  ###
  isValid: ->
    @valid

  ###*
  @method getErrors
  @return {Object} Errors found if raw data did not match the schema.
  ###
  getErrors: ->
    @errors

  ###*
  @method exists
  @param {String} key
  @return {q.promise}
  ###
  exists: ( key ) ->
    deferred = Q.defer()

    riakpbc.get( bucket: @bucket, key: key, ( err, reply ) ->
      if err
        if err.notFound
          deferred.resolve( true )
        else
          deferred.reject( new RiakError( err ) )
      else
        deferred.resolve( false )
    )

    deferred.promise

