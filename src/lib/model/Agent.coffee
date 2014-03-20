"use strict"
###*
@class joukou-api.model.Agent
@requires joukou-api.schema.Agent
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
###

module.exports = self = class

  ###*
  @static
  @property {joukou-api.schema.Agent} schema
  ###
  @schema = require( '../schema/Agent' )

  constructor: ( @rawData ) ->
    @data = self.schema.validate( @rawData )

  ###*
  @method isValid
  @returns {Boolean}
  ###
  isValid: ->
    @data.valid



