var port, schema;

schema = require('schemajs');

port = require('./port/schema');

module.exports = schema.create({
  name: {
    type: 'string+',
    required: true
  },
  description: {
    type: 'string'
  },
  icon: {
    type: 'string+'
  },
  image: {
    type: 'string'
  },
  subgraph: {
    type: 'boolean'
  },
  inports: {
    type: 'array',
    required: true,
    schema: port
  },
  outports: {
    type: 'array',
    required: true,
    schema: port
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
