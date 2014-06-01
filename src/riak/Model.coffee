"use strict"

###*
Lightweight model client for Basho Riak 2.0

Prefers the protocol buffers API, but may fall back to the HTTP API for missing
functionality.

Search is supported via solr-client.

@class joukou-api/riak/Model
@extends events.EventEmitter
@requires lodash
@requires q
@requires node-uuid
@requires riakpbc
@requires solr-client
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ EventEmitter } = require( 'events' )
_                = require( 'lodash' )
Q                = require( 'q' )
uuid             = require( 'node-uuid' )
NotFoundError    = require( './NotFoundError' )
pbc              = require( './pbc' )

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
      Expand a shortened content type to the full equivalent.
      @private
      @static
      @param {string} type
      @return {string}
      ###
      @_expandContentType = ( type ) ->
        switch type
          when 'json'
            'application/json'
          when 'xml', 'html', 'plain'
            'text/' + type
          when 'jpeg', 'gif', 'png'
            'image/' + type
          when 'binary'
            'application/octet-stream'
          else
            type

      ###*
      Create a new instance of `this` *Model* based on the provided raw client
      data.
      @param {Object.<string,(string|number)>} rawValue The raw data from the client.
      @return {q.promise}
      ###
      @create = ( rawValue ) ->
        deferred = Q.defer()

        # Check if the raw data is valid according to the schema
        { value, errors, valid } = self.getSchema().validate( rawValue )

        # If the raw data is invalid then reject the promise
        unless valid
          process.nextTick( ->
            deferred.reject( errors )
          )
          return deferred.promise

        # Autogenerate a key for this model instance
        key = uuid.v4()
        
        # Create a new model instance
        instance = new self( key: key, value: value )

        # Provide a hook for model definitions to inject post-create logic
        if self.afterCreate
          afterCreate = self.afterCreate( instance )
        else
          afterCreate = Q.fcall( -> instance )

        afterCreate.then( ( instance ) ->
          deferred.resolve( instance )
        ).fail( ( err ) ->
          deferred.reject( err )
        )

        deferred.promise

      @createFromReply = ( { key, reply } ) ->
        unless reply.content.length is 1
          throw new Error( 'Unhandled reply.content length' )

        content = reply.content[ 0 ]

        new self(
          type: self.getType()
          bucket: self.getBucket()
          key: key
          contentType: content.content_type
          lastMod: content.last_mod
          lastModUsecs: content.last_mod_usecs
          value: content.value
          vclock: reply.vclock
          vtag: content.vtag
        )

      ###*
      Retrieve an instance of this *Model* class from Basho Riak.
      @param {string} key
      @return {q.promise}
      ###
      @retrieve = ( key ) ->
        deferred = Q.defer()

        pbc.get(
          type: self.getType()
          bucket: self.getBucket()
          key: key
        , ( err, reply ) ->
          if err
            deferred.reject( err )
          else if _.isEmpty( reply )
            deferred.reject( new NotFoundError(
              type: self.getType()
              bucket: self.getBucket()
              key: key
            ) )
          else
            deferred.resolve( self.createFromReply( key: key, reply: reply ) )
        )

        deferred.promise

      ###*
      @constructor
      ###
      constructor: ( options ) ->
        {
          @contentType, @key, @lastMod, @lastModUsecs,
          @value, @vclock, @vtag, @indexes
        } = options

        @indexes ?= []

        @contentType = @_detectContentType()

        return

      getKey: ->
        @key

      getValue: ->
        @value

      setValue: ( @value ) ->

      ###*
      Persists `this` *Model* instance in Basho Riak.
      @return {q.promise}
      ###
      save: ->
        deferred = Q.defer()

        pbc.put( @_getPbParams(), ( err, reply ) ->
          if err
            deferred.reject( err )
          else
            deferred.resolve( self.createFromReply( key: @key, reply: reply ) )
        )

        deferred.promise

      ###*
      Get the params object suitable for sending to the server via the protocol
      buffers API.
      @return {!Object}
      ###
      _getPbParams: ->
        params = {}

        params.type = self.getType()
        params.bucket = self.getBucket()
        params.key = @key
        params.vclock = @vclock if @vclock
        # Turns on return body so that model instances can be re-created with
        # up-to-date vclocks etc after persisting values to Basho Riak.
        params.return_body = true

        content = {}
        content.value = @_getSerializedValue()
        content.content_type = @getContentType()
        content.vtag = @vtag if @vtag
        content.indexes = @_getSecondaryIndexes() if @_hasSecondaryIndexes()

        params.content = content

        params

      ###*
      Get a serialized representation of the value of `this` *Model* instance.
      @return {string}
      ###
      _getSerializedValue: ->
        switch @getContentType()
          when 'application/json'
            JSON.stringify( @value )
          else
            new Buffer( @value ).toString()

      getContentType: ->
        @contentType

      ###*
      Automatically detect the content type based on reflection of the value.
      @private
      @return {string}
      ###
      _detectContentType: ->
        if @contentType
          self._expandContentType( @contentType )
        else
          if @value instanceof Buffer
            self._expandContentType( 'binary' )
          else if typeof @value is 'object'
            self._expandContentType( 'json' )
          else
            self._expandContentType( 'plain' )

      addSecondaryIndex: ( key ) ->
        @indexes.push( key )
        @

      _hasSecondaryIndexes: ->
        @indexes.length > 0

      _getSecondaryIndexes: ->
        indexes = []
        for key in @indexes
          if @value.hasOwnProperty( key )
            indexes.push(
              key: @_getSecondaryIndexKey( key )
              value: @value[ key ]
            )
        indexes

      ###*
      Get the secondary index field name based on reflection of the value
      associated with the given `key`.
      ###
      _getSecondaryIndexKey: ( key ) ->
        if _.isNumber( @value[ key ] )
          "#{key}_int"
        else if _.isString( @value[ key ] )
          "#{key}_bin"
        else
          throw new Error( 'Invalid secondary index type' )
