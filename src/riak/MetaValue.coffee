###*
@class joukou-api/riak/Meta
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

module.exports = class

  self = @

  @keywords = [
    'bucket'
    'contentType'
    'key'
    'lastMod'
    'lastModUsecs'
    'type'
    'value'
    'vclock'
    'vtag'
  ]

  ###*
  Construct a *MetaValue* from a server reply.
  @static
  @return {joukou-api/riak/MetaValue}
  ###
  @fromReply = ( { type, bucket, key, reply } ) ->
    unless reply.content.length is 1
      throw new Error( 'Unhandled state exception' )

    content = reply.content[ 0 ]

    new self(
      type: type
      bucket: bucket
      key: key
      contentType: content.content_type
      lastMod: content.last_mod
      lastModUsecs: content.last_mod_usecs
      value: content.value
      vclock: reply.vclock
      vtag: content.vtag
    )

  ###*
  @constructor
  ###
  constructor: ( options = {} ) ->
    Object.keys( options ).forEach( ( key ) =>
      if ~self.keywords.indexOf( key )
        @[ key ] = options[ key ]
    )

    @contentType = @_detectContentType()

    return

  getValue: ->
    @value

  ###*
  Get the *Model* associated with `this` *MetaValue*.
  @return {joukou-api/riak/Model}
  ###
  getModel: ->
    @model

  ###*
  Set the *Model* associated with `this` *MetaValue*.
  @param {joukou-api/riak/Model} model
  ###
  setModel: ( @model ) ->

  ###*
  Get the params object suitable for sending to the sever via the protocol
  buffers API.
  @return {!Object}
  ###
  getParams: ->
    params = {}

    params.type = @type if @type
    params.bucket = @bucket
    params.key = @key
    params.vclock = @vclock if @vclock

    content = {}
    content.value = @getSerializedValue()
    content.content_type = @getContentType()
    content.vtag = @vtag if @vtag

    params.content = content

    params

  ###*
  Get a serialized representation of the value.
  @return {string}
  ###
  getSerializedValue: ->
    switch @getContentType()
      when 'application/json'
        JSON.stringify( @value )
      else
        new Buffer( @value ).toString()

  ###*
  Automatically detect the content type based on reflection of the value.
  @private
  @return {string}
  ###
  _detectContentType: ->
    if @contentType
      @_expandContentType( @contentType )
    else
      if @value instanceof Buffer
        @_expandContentType( 'binary' )
      else if typeof @value is 'object'
        @_expandContentType( 'json' )
      else
        @_expandContentType( 'plain' )

  ###*
  Expand a shortened content type to the full equivalent.
  @private
  @param {string} type
  @return {string}
  ###
  _expandContentType: ( type ) ->
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

  getContentType: ->
    @contentType




