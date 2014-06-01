"use strict";

/**
An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.

@module joukou-api/agent/model
@requires joukou-api/agent/schema
@requires joukou-api/riak/Model
@requires joukou-api/error/BcryptError
@requires lodash
@requires q
@requires bcrypt
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var BcryptError, Model, Q, agentModel, bcrypt, schema, _;

_ = require('lodash');

Q = require('q');

bcrypt = require('bcrypt');

schema = require('./schema');

Model = require('../riak/Model');

BcryptError = require('../error/BcryptError');

agentModel = Model.define({
  schema: schema,
  bucket: 'agent'
});

agentModel.prototype.verifyPassword = function(password) {
  var deferred;
  deferred = Q.defer();
  bcrypt.compare(password, this.getValue().password, function(err, authenticated) {
    if (err) {
      return deferred.reject(new BcryptError(err));
    } else {
      return deferred.resolve(authenticated);
    }
  });
  return deferred.promise;
};

agentModel.beforeCreate = function(value) {
  var deferred;
  deferred = Q.defer();
  bcrypt.getSalt(10, function(err, salt) {
    if (err) {
      return deferred.reject(new BcryptError(err));
    } else {
      return bcrypt.hash(value.password, salt, function(err, hash) {
        if (err) {
          return deferred.reject(new BcryptError(err));
        } else {
          value.password = hash;
          return deferred.resolve(value);
        }
      });
    }
  });
  return deferred.promise;
};

module.exports = agentModel;

/*
//# sourceMappingURL=model.js.map
*/
