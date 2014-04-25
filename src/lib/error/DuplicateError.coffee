"use strict"

###*
@class joukou-api.error.DuplicateError
@extends restify.RestError
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
  @param {String} indexName
  ###
  constructor: (@indexName) ->
    super(
      restCode: 'DuplicateError'
      statusCode: 409
      message: @indexName
      constructorOpt: self.DuplicateError
    )