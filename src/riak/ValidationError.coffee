###*
@class joukou-api/riak/ValidationError
@extends restify/RestError
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ RestError } = require( 'restify' )

module.exports = self = class extends RestError
  constructor: ( errors ) ->
    super(
      restCode: 'ForbiddenError'
      statusCode: 403
      message: JSON.stringify( errors )
      constructorOpt: self
    )
    return