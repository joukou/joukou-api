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
{ NotFoundError } = require( 'restify' )
ValidationError  = require( './ValidationError' )
RiakError        = require( './RiakError' )
pbc              = require( './pbc' )

module.exports =

  define: ( { type, bucket, schema } ) ->

    type ?= 'default'

    unless _.isString( bucket )
      throw new TypeError( 'type is not a string' )

    unless _.isObject( schema ) and _.isFunction( schema.validate )
      throw new TypeError( 'schema is not a schema object' )

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
      @create = ( rawValue = {} ) ->
        deferred = Q.defer()

        # Check if the raw data is valid according to the schema
        { data, errors, valid } = self.getSchema().validate( rawValue )

        # If the raw data is invalid then reject the promise
        unless valid
          process.nextTick( ->
            deferred.reject( new ValidationError( errors ) )
          )
          return deferred.promise

        # Autogenerate a key for this model instance
        key = uuid.v4()
        
        # Create a new model instance
        instance = new self( key: key, value: data )

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

        ret = new self(
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

        if content and content.indexes
          for index in content.indexes
            ret.addSecondaryIndex(index.key)

        ret
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
            deferred.reject( new RiakError( err ) )
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
      Retrieve a collection of instances of this *Model* class from Basho Riak
      via a secondary index query.
      @param {string} index
      @param {string} key
      ###
      @retrieveBySecondaryIndex = ( index, key, firstOnly = false ) ->
        deferred = Q.defer()

        pbc.getIndex(
          type: self.getType()
          bucket: self.getBucket()
          index: index
          qtype: 0
          key: key
          # return_terms: true - this only works with streaming data
        , ( err, reply ) ->
          if err
            deferred.reject( new RiakError( err ) )
          else if _.isEmpty( reply )
            deferred.reject( new NotFoundError(
              type: self.getType()
              bucket: self.getBucket()
              key: key
            ) )
          else
            if firstOnly
              deferred.resolve( self.retrieve( _.first( reply.keys ) ) )
            else
              deferred.resolve( _.map( reply.keys, ( key ) ->
                self.retrieve( key )
              ) )
        )

        deferred.promise

      @delete = ( key ) ->
        deferred = Q.defer()

        pbc.del(
          type: self.getType()
          bucket: self.getBucket()
          key: key
        , ( err, reply ) ->
          if err
            deferred.reject( new RiakError( err ) )
          else
            deferred.resolve()
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

        pbc.put( @_getPbParams(), ( err, reply ) =>
          if err
            deferred.reject( new RiakError( err ) )
          else
            deferred.resolve( self.createFromReply( key: @key, reply: reply ) )
        )

        deferred.promise

      delete: ->
        self.delete( @getKey() )

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
        if key.indexOf("_bin") isnt -1 or key.indexOf("_int") isnt -1
          return key
        if _.isNumber( @value[ key ] )
          "#{key}_int"
        else if _.isString( @value[ key ] )
          "#{key}_bin"
        else
          throw new Error( 'Invalid secondary index type' )
