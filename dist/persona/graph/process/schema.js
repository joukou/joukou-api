var schema;

schema = require('schemajs');

module.exports = schema.create({
  metadata: {
    type: "object"
  },
  circle: {
    type: "object",
    schema: {
      key: {
        type: "string+"
      }
    }
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
