"use strict";

/**
@class joukou-api.schema.Agent
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
 */
var schema;

schema = require('schemajs');

module.exports = schema.create({
  name: {
    type: 'string',
    filters: ['trim']
  },
  email: {
    type: 'email',
    required: true,
    allownull: false
  },
  password: {
    type: 'string+',
    required: true,
    allownull: false,
    filters: ['trim'],
    properties: {
      min: 6,
      max: 33
    }
  }
});

/*
//# sourceMappingURL=Agent.js.map
*/