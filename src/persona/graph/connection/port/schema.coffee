###*
@module joukou-api/persona/graph/connection/port/schema
@author Fabian Cook <fabian.cook@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

schema = require( 'schemajs' )

module.exports = schema.create(
  process:
    type: "string+"
    required: true
  port:
    type: "string+"
    required: true
)