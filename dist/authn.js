"use strict";

/**
Authentication based on Passport.

@module joukou-api/authn
@requires lodash
@requires bcrypt
@requires passport
@requires passport-http
@requires util
@requires joukou-api/riak/client
@requires joukou-api/error/BcryptError
@requires joukou-api/error/RiakError
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var BasicStrategy, passport, riak, self, verify, _;

_ = require('lodash');

passport = require('passport');

BasicStrategy = require('passport-http').BasicStrategy;

riak = require('./riak/client');


/**
@private
@func verify
@param {string} username The user's email address
@param {string} password The user's plaintext password
@param {function(Error,*)} next
 */

verify = function(username, password, next) {
  var agent;
  agent = agentModel.loadByUsername(username);
  return agent.verifyPassword(password).then(function(authenticated) {
    if (authenticated) {
      return next(null, agent);
    } else {
      return next(null, false);
    }
  }).fail(function(err) {
    return next(err);
  });
};

passport.use(new BasicStrategy(verify));

module.exports = self = {

  /**
  @func middleware
   */
  middleware: function() {
    return passport.initialize();
  },

  /**
  @func authenticate
   */
  authenticate: passport.authenticate('basic', {
    session: false
  })
};

/*
//# sourceMappingURL=authn.js.map
*/
