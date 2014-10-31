schema = require( 'schemajs' )
port   = require( './port/schema' )

module.exports = schema.create(
  name:
    type: 'string+'
    required: yes
  description:
    type: 'string'
  icon:
    type: 'string+'
  # Docker image
  image:
    type: 'string'
  subgraph:
    type: 'boolean'
  inports:
    type: 'array'
    required: yes
    schema: port
  outports:
    type: 'array'
    required: yes
    schema: port
)