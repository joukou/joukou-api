"use strict";

/**
@module joukou-api/persona/schema
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.com>
 */
var schema;

schema = require('schemajs');

module.exports = schema.create({
  name: {
    type: 'string+',
    required: true,
    allownull: false,
    filters: ['trim']
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
