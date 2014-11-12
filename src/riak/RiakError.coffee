###*
@class joukou-api/riak/RiakError
@extends restify/RestError
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ RestError } = require( 'restify' )

module.exports = self = class extends RestError
  constructor: ( @originalError, model, params ) ->
    super(
      restCode: 'InternalError'
      statusCode: 503
      message: 'The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.'
      constructorOpt: self
    )
    this.InnerError = originalError
    this.model = model
    this.params = params
    return