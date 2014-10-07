"use strict";

/**
Authentication based on Passport.

@module joukou-api/authn
@requires passport
@requires passport-github
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var AgentModel, GithubStrategy, NotFoundError, Q, UnauthorizedError, env, githubEnv, githubProfileToAgent, passport, self, verify, _ref;

passport = require('passport');

GithubStrategy = require('passport-github').Strategy;

AgentModel = require('./agent/Model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

env = require('./env');

Q = require('q');

githubProfileToAgent = function(profile, agent) {
  var created, deferred;
  deferred = Q.defer();
  profile = profile._json || profile;
  if (!profile) {
    deferred.reject(new Error("Profile not provided"));
    return;
  }
  if (!profile.email || !profile.id || !profile.name) {
    deferred.reject(new Error("Required details not provided"));
    return;
  }
  created = function(actualAgent) {
    actualAgent.setValue({
      email: profile.email,
      githubLogin: profile.login,
      githubId: profile.id,
      imageUrl: profile.avatar_url,
      website: profile.blog,
      githubUrl: profile.url,
      name: profile.name,
      company: profile.company,
      location: profile.location
    });
    actualAgent.save().then(function(agent) {
      return deferred.resolve(agent);
    }).fail(function(err) {
      return deferred.reject(err);
    });
    return void 0;
  };
  if (agent) {
    created(agent);
  } else {
    AgentModel.create({
      email: profile.email
    }).then(created).fail(deferred.reject);
  }
  return deferred.promise;
};


/**
@private
@func verify
@param {string} accessToken
@param {string} refreshToken
@param {object} profile
@param {function(Error,*)} next
 */

verify = function(accessToken, refreshToken, profile, next) {
  var saveOrCreate;
  saveOrCreate = function(agent) {
    return githubProfileToAgent(profile, agent).then(function(agent) {
      return next(null, agent);
    }).fail(function(err) {
      return next(err);
    });
  };
  return AgentModel.retriveByGithubId(profile.id).then(function(agent) {
    return saveOrCreate(agent);
  }).fail(function(err) {
    if (!(err instanceof NotFoundError)) {
      next(err);
      return;
    }
    return saveOrCreate(null);
  });
};

githubEnv = env.getGithubAuth();

passport.use(new GithubStrategy({
  clientID: githubEnv.clientId,
  clientSecret: githubEnv.clientSecret,
  callbackURL: githubEnv.callbackUrl
}, verify));

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
  authenticate: passport.authenticate('github', {
    session: false,
    failureRedirect: '/agent/authenticate/failed'
  })
};

/*
//# sourceMappingURL=authn.js.map
*/
