"use strict"

###*
Client for Basho Riak 2.0.

Prefers the protocol buffer API, but may fall back to HTTP for missing
functionality.

Search is implemented via solr-client.

@class joukou-api/riak/Client
@requires lodash
@requires q
@requires riakpbc
@requires solr-client
###

module.exports = new class

  self          = @
  _             = require( 'lodash' )
  Q             = require( 'q' )
  riakpbc       = require( 'riakpbc' )
  MetaValue     = require( './MetaValue' )
  NotFoundError = require( './NotFoundError' )

  ###*
  @constructor
  ###
  constructor: ( options = {} ) ->
    @pbc = riakpbc.createClient(
      host: options.pbHost or 'localhost'
      port: options.pbPort or 8087
    )

    return

  ###*
  Fetch a *Value* from the specified bucket type/bucket/key location (specified
  by `type`, `bucket`, and `key` respectively). If the bucket `type` is not
  specified, the `default` bucket type will be used.
  @return {q.promise}
  ###
  get: ( { type, bucket, key } ) ->
    deferred = Q.defer()

    type ?= 'default'

    @pbc.get( bucket: bucket, key: key, type: type, ( err, reply ) ->
      if err
        deferred.reject( err )
      else if _.isEmpty( reply )
        deferred.reject( new NotFoundError() )
      else
        metaValue = MetaValue.fromReply(
          type: type
          bucket: bucket
          key: key
          reply: reply
        )

        deferred.resolve( metaValue )
    )

    deferred.promise

  ###*
  Stores a `value` under the specified `bucket` and `key`, or under the `bucket`
  and `key` provided by the `metaValue` object.
  @param {string} bucket
  @param {string} key
  @param {joukou-api/riak/Value} value
  @param {joukou-api/riak/Meta} meta
  @return {q.promise}
  ###
  put: ( { bucket, key, value, metaValue } ) ->
    deferred = Q.defer()

    if not metaValue and (bucket and key and value)
      metaValue = new MetaValue(
        bucket: bucket
        key: key
        value: value
      )

    @pbc.put(metaValue.getParams(), ( err, reply ) ->
      if err
        deferred.reject( err )
      else
        deferred.resolve( reply )
    )

    deferred.promise
