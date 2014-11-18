var schema;

schema = require('schemajs');

module.exports = schema.create({
  id: {
    type: "string+",
    required: true
  },
  name: {
    type: "string+",
    required: true
  },
  description: {
    type: "string"
  },
  addressable: {
    type: "boolean"
  },
  required: {
    type: "boolean"
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
