"use strict"

###*
@module joukou-api/graph/schema
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

schema = require( 'schemajs' )

module.exports = schema.create(
  properties:
    type: 'object'
  processes:
    type: 'object'
  connections:
    type: 'array'
  personas:
    type: 'array'
)