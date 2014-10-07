"use strict";

/**
@module joukou-api/agent/schema
@requires schemajs
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var schema;

schema = require('schemajs');


/*
agent.email = profile.email
agent.githubLogin = profile.login
agent.githubId = profile.id
agent.imageUrl = profile.avatar_url
agent.website = profile.blog
agent.githubUrl = profile.url
agent.name = profile.name
agent.company = profile.company
agent.location = profile.location
 */

module.exports = schema.create({
  email: {
    type: 'email',
    required: true,
    allownull: false,
    filters: ['trim']
  },
  githubLogin: {
    type: 'string',
    required: false,
    allownull: true
  },
  githubId: {
    type: 'integer',
    required: false,
    allownull: true
  },
  imageUrl: {
    type: 'string',
    required: false,
    allownull: false
  },
  website: {
    type: 'url',
    required: false,
    allownull: false
  },
  githubUrl: {
    type: 'url',
    required: false,
    allownull: false
  },
  name: {
    type: 'string',
    required: false,
    allownull: false
  },
  company: {
    type: 'string',
    required: false,
    allownull: false
  },
  location: {
    type: 'string',
    required: false,
    allownull: false
  }
});

/*
//# sourceMappingURL=schema.js.map
*/
