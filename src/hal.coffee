"use strict"

###*
@module joukou-api/hal
@requires lodash
@requires assert-plus
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.com>

application/hal+json middleware for restify.
###
_           = require('lodash')
assert      = require('assert-plus')

module.exports =
  ###*
  application/hal+json formatter
  @static
  @func formatter
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Object} body
  @return {Object}
  ###
  formatter: ( req, res, body ) ->
    # Binary data
    if Buffer.isBuffer( body )
      data = body.toString( 'base64' )
      res.setHeader( 'Content-Length', Buffer.byteLength( data ) )
      return data

    # Error
    if body instanceof Error
      res.setHeader('Content-Type', 'application/vnd.error+json')
      res.statusCode = body.statusCode or 500
      body =
        logref: body.restCode
        message: body.message
        _links: res._links

    # HAL+JSON
    else
      res.link(req.path(), 'self')
      res.link( 'https://rels.joukou.com/{rel}', 'curies', { name: 'joukou', templated: true } )
      body._links = res._links

    data = JSON.stringify(body)
    res.setHeader('Content-Length', Buffer.byteLength(data))

    data

  ###*
  application/hal+json link middleware
  @static
  @func link
  @return {Function}
  ###
  link: ->
    (req, res, next) ->
      ###*
      @class http.ServerResponse
      @method link
      @param {http.ClientRequest} req
      @param {http.ServerResponse} res
      @param {Function} next
      ###
      res.link = ( href, rel, props = {} ) ->
        assert.string( href )
        assert.string( rel )

        @_links ?= {}
        ( @_links[ rel ] ?= [] ).push( _.extend( props,
          href: href
        ) )

      next()