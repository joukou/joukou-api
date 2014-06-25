"use strict";

/**
@module joukou-api/agent/schema
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var schema;

schema = require('schemajs');

module.exports = schema.create({
  email: {
    type: 'email',
    required: true,
    allownull: false,
    filters: ['trim']
  },
  password: {
    type: 'string+',
    required: true,
    allownull: false,
    filters: ['trim'],
    properties: {
      min: 6,
      max: 42
    }
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
