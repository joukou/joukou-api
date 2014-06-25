"use strict";

/**
Authentication based on Passport.

@module joukou-api/authn
@requires passport
@requires passport-http
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var AgentModel, BasicStrategy, NotFoundError, UnauthorizedError, passport, self, verify, _ref;

passport = require('passport');

BasicStrategy = require('passport-http').BasicStrategy;

AgentModel = require('./agent/Model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;


/**
@private
@func verify
@param {string} username The user's email address
@param {string} password The user's plaintext password
@param {function(Error,*)} next
 */

verify = function(username, password, next) {
  return AgentModel.retrieveByEmail(username).then(function(agent) {
    return agent.verifyPassword(password).then(function(authenticated) {
      if (authenticated) {
        return next(null, agent);
      } else {
        return next(null, false);
      }
    });
  }).fail(function(err) {
    if (err instanceof NotFoundError) {
      err = new UnauthorizedError();
    }
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
