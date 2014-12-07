"use strict";

/**
@module joukou-api/persona/graph/schema
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var network, schema;

schema = require('schemajs');

network = require('./network/schema');

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
  },
  network: {
    type: 'object',
    schema: network.schema
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
