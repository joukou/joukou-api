"use strict";

/**
An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.

@class joukou-api/agent/Model
@requires joukou-api/agent/schema
@requires joukou-api/riak/Model
@requires joukou-api/error/BcryptError
@requires lodash
@requires q
@requires bcrypt
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var AgentModel, BcryptError, Model, Q, bcrypt, schema, _;

_ = require('lodash');

Q = require('q');

bcrypt = require('bcrypt');

schema = require('./schema');

Model = require('../riak/Model');

BcryptError = require('../error/BcryptError');

AgentModel = Model.define({
  schema: schema,
  bucket: 'agent'
});


/**
Before creating an agent, encrypt the password with bcrypt.
 */

AgentModel.beforeCreate = function(metaValue) {
  var deferred;
  deferred = Q.defer();
  bcrypt.getSalt(10, function(err, salt) {
    if (err) {
      return deferred.reject(new BcryptError(err));
    } else {
      return bcrypt.hash(metaValue.getValue().password, salt, function(err, hash) {
        if (err) {
          return deferred.reject(new BcryptError(err));
        } else {
          metaValue.setValue(_.assign(metaValue.getValue(), {
            password: hash
          }));
          return deferred.resolve(metaValue);
        }
      });
    }
  });
  return deferred.promise;
};


/**
Verify the given `password` against the stored password.
@method verifyPassword
@return {q.promise}
 */

AgentModel.prototype.verifyPassword = function(password) {
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

AgentModel.prototype.getRepresentation = function() {
  return _.pick(this.getValue(), ['username', 'roles', 'name']);
};

AgentModel.prototype.getUsername = function() {
  return this.getValue().username;
};

AgentModel.prototype.getName = function() {
  return this.getValue().name;
};

AgentModel.prototype.getRoles = function() {
  return this.getValue().roles;
};

AgentModel.prototype.hasRole = function(agent, role) {
  var roles;
  roles = [role];
  return this.hasSomeRoles(roles);
};

AgentModel.prototype.hasSomeRoles = function(agent, roles) {
  return _.some(roles, (function(_this) {
    return function(role) {
      return _this.getRoles().indexOf(role) !== -1;
    };
  })(this));
};

module.exports = AgentModel;

/*
//# sourceMappingURL=Model.js.map
*/
