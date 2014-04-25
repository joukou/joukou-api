"use strict";

/**
@class joukou-api.schema.User
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var schema;

schema = require('schemajs');

module.exports = schema.create({
  username: {
    type: 'string+',
    required: true,
    allownull: false,
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
      max: 30
    }
  }
});

/*
//# sourceMappingURL=User.js.map
*/
