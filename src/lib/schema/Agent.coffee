"use strict"
###*
@class joukou-server.schema.Agent
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
###

schema = require( 'schemajs' )

module.exports = schema.create(
  name:
    type: 'string'
    filters: [ 'trim' ]
  email:
    type: 'email'
    required: true
    allownull: false
  password:
    type: 'string+'
    required: true
    allownull: false
    filters: [ 'trim' ]
    properties:
      min: 6
      max: 33
)

