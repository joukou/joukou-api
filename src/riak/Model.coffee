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
_                = require( 'lodash' )
Q                = require( 'q' )
uuid             = require( 'node-uuid' )
riak             = require( './Client' )
MetaValue        = require( './MetaValue' )

module.exports =

  define: ( { type, bucket, schema } ) ->

    type ?= 'default'

    class extends EventEmitter

      self = @

      @getType = ->
        type

      @getBucket = ->
        bucket

      @getSchema = ->
        schema

      ###*
      Create a new *Value* for `this` *Model* in Basho Riak.
      @param {Object.<string,(string|number)>} rawValue The raw data from the client.
      @return {q.promise}
      ###
      @create = ( rawValue ) ->
        deferred = Q.defer()

        { value, errors, valid } = self.getSchema().validate( rawValue )

        unless valid
          process.nextTick( ->
            deferred.reject( errors )
          )
          return deferred.promise

        if self.beforeCreate
          beforeCreate = self.beforeCreate( value )
        else
          beforeCreate = Q.fcall( -> value )

        beforeCreate.then( ( value ) ->

          metaValue = new MetaValue(
            type: @getType()
            bucket: @bucket
            key: uuid.v4()
            value: value
          )

          riak.put( metaValue: metaValue ).then( ->
            deferred.resolve( new self( metaValue: metaValue ) )
          ).fail( ( err ) ->
            deferred.reject( err )
          )

        )

        deferred.promise

      ###*
      Retrieve a *Model* instance of this *Model* class from Basho Riak.
      @param {string} key
      @return {q.promise}
      ###
      @retrieve = ( key ) ->
        deferred = Q.defer()

        riak.get(
          type: self.getType()
          bucket: self.getBucket()
          key: key
        ).then( ( metaValue ) ->
          deferred.resolve( new self(
            metaValue: metaValue
          ) )
        ).fail( ( err ) ->
          deferred.reject( err )
        )

        deferred.promise

      ###*
      @constructor
      ###
      constructor: ( { @metaValue } ) ->

      ###*
      Get the *MetaValue* instance for `this` *Modal* instance.
      @return {joukou-api/riak/MetaValue}
      ###
      getMetaValue: ->
        @metaValue

      ###*
      Get value of the *MetaValue* instance for `this` *Modal* instance.
      @return {!Object}
      ###
      getValue: ->
        @getMetaValue().getValue()


