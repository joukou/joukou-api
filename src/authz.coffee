"use strict"

###*
Authorization.

@module joukou-api/authz
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

module.exports =

  ###*
  Check if the given `agent` has the given `permission`.
  ###
  hasPermission: ( agent, permission ) ->
