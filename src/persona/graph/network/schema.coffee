schema = require('schemajs')

module.exports = schema.create(
  metadata:
    type: 'object'
  desiredState:
    type: 'boolean'
)