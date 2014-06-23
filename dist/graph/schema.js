"use strict";

/**
@module joukou-api/graph/schema
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var schema;

schema = require('schemajs');

module.exports = schema.create({
  name: {
    type: 'string+'
  },
  processes: {
    type: 'object'
  },
  connections: {
    type: 'array'
  },
  personas: {
    type: 'array'
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
