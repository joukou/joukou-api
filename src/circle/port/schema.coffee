schema = require( 'schemajs' )

module.exports = schema.create(
  id:
    type: "string+"
    required: yes
  name:
    type: "string+"
    required: yes
  description:
    type: "string"
  addressable:
    type: "boolean"
  required:
    type: "boolean"
)