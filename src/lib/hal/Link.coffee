"use strict"
###*
@class joukou-server.hal.Link
@requires lodash
@requires assert
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
###

_       = require( 'lodash' )
assert  = require( 'assert-plus' )

module.exports = ( req, res, next ) ->
  ###*
  @class http.ServerResponse
  @method link
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  res.__proto__.link = ( href, rel, props = {} ) ->
    assert.string( href )
    assert.string( rel )

    @_links ?= {}
    ( @_links[ rel ] ?= [] ).push(
      _.extend( props,
        href: href
      )
    )

    next()