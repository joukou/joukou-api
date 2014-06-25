"use strict";

/**
@module joukou-api/persona/graph/connection/schema
@requires joukou-api/hyper/Schema
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var HyperSchema;

HyperSchema = require('../../hyper/Schema');

module.exports = HyperSchema.define({
  properties: {
    metadata: {
      type: 'object'
    },
    data: {
      type: 'string+'
    }
  },
  links: {
    'joukou:process': {
      min: 2,
      max: 2,
      href: '/persona/:personaKey/graph/:graphKey/process/:key',
      properties: {
        name: {
          required: true,
          type: 'enum',
          values: ['src', 'tgt']
        }
      }
    }
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
