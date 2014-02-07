###*
@class joukou-server.error.BcryptError
@extends restify.RestError
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
###

module.exports = self = class extends RestError
  constructor: ( @originalError ) ->
    super(
      restCode: 'InternalError'
      statusCode: 503
      message: '' # TODO
      constructorOpt: self
    )