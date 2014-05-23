###*
@class joukou-api/error/RiakError
@extends restify/RestError
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

{ RestError } = require( 'restify' )

module.exports = class extends RestError

  ###*
  @private
  @static
  @property {joukou-api.error.DuplicateError} self
  ###
  self = @

  ###*
  @method constructor
  @param {Error} originalError
  ###
  constructor: ( @originalError ) ->
    super(
      restCode: 'InternalError'
      statusCode: 503
      message: '' # TODO
      constructorOpt: self
    )
