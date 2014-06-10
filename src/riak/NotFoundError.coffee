###*
@class joukou-api/riak/NotFoundError
@extends restify/RestError
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ RestError } = require( 'restify' )

module.exports = self = class extends RestError
  constructor: ( message ) ->
    super(
      restCode: 'NotFound'
      statusCode: 404
      message: message
      constructorOpt: self
    )
    @notFound = true
    return