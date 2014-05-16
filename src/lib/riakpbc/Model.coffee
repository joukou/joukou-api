"use strict"

###*
@class joukou-api/riakpbc/Model
@extends events.EventEmitter
@requires lodash
@requires q
@requires node-uuid
@requires joukou-api/riakpbc/client
@requires joukou-api/error/RiakError
@requires restify/NotFoundError
@requires joukou-api/riakpbc/Value
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ EventEmitter } = require( 'events' )

module.exports = self = class extends EventEmitter

  self              = @
  _                 = require( 'lodash' )
  Q                 = require( 'q' )
  uuid              = require( 'node-uuid' )
  riakpbc           = require( './client' )
  RiakError         = require( '../error/RiakError' )
  { NotFoundError } = require( 'restify' )
  Value             = require( './Value' )

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
  constructor: ( { @schema, @bucket } ) ->
    return

  ###*
  Load a *Value* for `this` *Model* from Basho Riak.
  @param {string} key
  @return {q.promise}
  ###
  load: ( key ) ->
    deferred = Q.defer()

    riakpbc.get( bucket: @bucket, key: key, ( err, reply ) ->
      if err
        if err.notFound
          deferred.reject( new NotFoundError( err ) )
        else
          deferred.reject( new RiakError( err ) )
      else
        deferred.resolve(
          new Value( model: @, key: key, riakData: reply.content ) )
      return
    )

    deferred.promise

  ###*
  Create a new *Value* for `this` *Model* in Basho Riak.
  @param {Object.<string,(string|number)>} rawData The raw data from the client.
  @return {q.promise}
  ###
  create: ( rawData ) ->
    deferred = Q.defer()

    value = new Value( model: @, key: uuid.v4(), rawData: rawData )

    unless value.isValid()
      deferred.reject()
    else
      value.save().then( ->
        deferred.resolve( value )
      ).fail( ( err ) ->
        deferred.reject( err )
      )
