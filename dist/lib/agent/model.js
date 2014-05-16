"use strict";

/**
An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.

@module joukou-api/agent/model
@requires joukou-api/agent/schema
@requires lodash
@requires q
@requires bcrypt
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var BcryptError, DuplicateError, Model, Q, RiakError, bcrypt, riakpbc, schema, verifyPassword, _;

_ = require('lodash');

Q = require('q');

bcrypt = require('bcrypt');

BcryptError = require('../error/BcryptError');

RiakError = require('../error/RiakError');

DuplicateError = require('../error/DuplicateError');

riakpbc = require('../riakpbc/client');

schema = require('./schema');

Model = require('../riakpbc/Model');

module.exports = Model.factory({
  schema: schema,
  bucket: 'agent'
});

verifyPassword = function(password) {
  var deferred;
  deferred = Q.defer();
  bcrypt.compare(password, this.data.password, function(err, authenticated) {
    if (err) {
      return deferred.reject(new BcryptError(err));
    } else {
      return deferred.resolve(authenticated);
    }
  });
  return deferred.promise;
};

/*
//# sourceMappingURL=model.js.map
*/
