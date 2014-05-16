"use strict"

###*
@class joukou-api/riakpbc/Value
###

{ EventEmitter } = require( 'events' )

module.exports = class extends EventEmitter

  self = @

  ###*
  @constructor
  ###
  constructor: ( { @key, @model, @rawData, @riakData } ) ->
    @phantom = !!@rawData

  validate: ->
    if @rawData
      { @valid, @data, @errors } = @model.getSchema().validate( @rawData )
    else
      @valid = true
      @data = @riakData
    @valid

  isValid: ->
    @valid

  getErrors: ->
    @errors

  ###*
  Check if an object already exists in Basho Riak with the same `bucket` and
  `key` as this model instance.
  @return {q.promise}
  ###
  exists: ->
    deferred = Q.defer()

    riakpbc.get( bucket: @bucket, key: @key, ( err, reply ) ->
      if err
        if err.notFound
          deferred.resolve( true )
        else
          deferred.reject( new RiakError( err ) )
      else
        deferred.resolve( false )
    )

    deferred.promise

  ###*
  Persist this model instance in Basho Riak. Uses {@link #exists|exists} to
  check if an object already exists in Basho Riak with the same `bucket` and
  `key` as this model instance, and rejects the promise if it does.
  @return {q.promise}
  ###
  save: ->
    deferred = Q.defer()

    @exists().then( ( exists ) =>
      if exists
        deferred.reject( new DuplicateError( @key ) )
      else
        riakpbc.put(
          bucket: @bucket
          key: @data[ @key ]
          content: @data
        , ( err, reply ) ->
          if err
            deferred.reject( new RiakError( err ) )
          else
            deferred.resolve()
        )
    )

    deferred.promise