"use strict"

###*
@class joukou-api.routes.index
@author Juan Morales <juan@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

users = require('./Users')

module.exports =
  registerRoutes: ( server ) ->
    users.registerRoutes( server )