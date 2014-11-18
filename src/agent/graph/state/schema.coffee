schema = require( 'schemajs' )


module.exports = schema.create(
  graph_key:
    type: 'string+'
    required: true
  agent_key:
    type: "string+"
    required: true
  scale:
    type: 'number'
  x:
    type: 'number'
  y:
    type: 'number'
)