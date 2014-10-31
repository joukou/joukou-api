
/**
@module joukou-api/persona/graph/connection/schema
@author Fabian Cook <fabian.cook@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var port, schema;

schema = require('schemajs');

port = require('./port/schema');

module.exports = schema.create({
  metadata: {
    type: "object"
  },
  data: {
    type: "string+"
  },
  src: {
    type: "object",
    required: true,
    schema: port
  },
  tgt: {
    type: "object",
    required: true,
    schema: port
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
