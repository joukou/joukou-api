"use strict"

###*
@class joukou-api/riak/Model
@extends events.EventEmitter
@requires lodash
@requires q
@requires node-uuid
@requires joukou-api/riak/Client
@requires joukou-api/riak/MetaValue
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ EventEmitter } = require( 'events' )

module.exports = self = class extends EventEmitter

  self              = @
  _                 = require( 'lodash' )
  Q                 = require( 'q' )
  uuid              = require( 'node-uuid' )
  riak              = require( './Client' )
  MetaValue         = require( './MetaValue' )

  ###*
  Create a model definition.
  @function factory
  @static
  ###
  @factory = ( options ) ->
    new self( options )

  ###*
  @constructor
  ###
  constructor: ( { @bucket, @schema } ) ->
    return

  ###*
  @return {string} The bucket name.
  ###
  getBucket: ->
    @bucket

  ###*
  @return {schemajs} The schema.
  ###
  getSchema: ->
    @schema

  ###*
  Load a *Value* for `this` *Model* from Basho Riak.
  @param {string} key
  @return {q.promise}
  ###
  load: ( key ) ->
    deferred = Q.defer()

    riak.get( bucket: @bucket, key: key ).then( ( metaValue ) =>
      metaValue.setModel( @ )
      deferred.resolve( metaValue )
    ).fail( ( err ) ->
      deferred.reject( err )
    )

    deferred.promise

  ###*
  Create a new *Value* for `this` *Model* in Basho Riak.
  @param {Object.<string,(string|number)>} rawValue The raw data from the client.
  @return {q.promise}
  ###
  create: ( rawValue ) ->
    deferred = Q.defer()

    { value, errors, valid } = @getSchema().validate( rawValue )

    unless valid
      process.nextTick( ->
        deferred.reject( errors )
      )
      return deferred.promise

    metaValue = new MetaValue(
      bucket: @bucket
      key: uuid.v4()
      value: value
    )

    riak.put( metaValue: metaValue ).then( ->
      deferred.resolve( value, meta )
    ).fail( ( err ) ->
      deferred.reject( err )
    )

    deferred.promise