"use strict"
###*
@class joukou-api.routes.index
@author Juan Morales <juan@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

agents  = require('./Agents')

module.exports =
  registerRoutes: (server) ->
    agents.registerRoutes(server)