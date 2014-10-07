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
var AgentModel, BearerStrategy, GithubStrategy, NotFoundError, Q, UnauthorizedError, authenticate, authenticateToken, env, generateTokenFromAgent, githubEnv, githubProfileToAgent, jwt, passport, passportBearer, self, verify, verifyToken, _ref;

passport = require('passport');

passportBearer = require('passport');

GithubStrategy = require('passport-github').Strategy;

AgentModel = require('./agent/Model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

env = require('./env');

Q = require('q');

BearerStrategy = require('passport-http-bearer').Strategy;

jwt = require('jsonwebtoken');

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
      return next(null, agent.getValue());
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

verifyToken = function(token, next) {
  var email, notAuth, obj;
  obj = jwt.decode(token);
  notAuth = function() {
    return next(new UnauthorizedError());
  };
  if (!obj || !(obj instanceof Object)) {
    notAuth();
    return;
  }
  email = null;
  if (typeof obj["email"] === "string") {
    email = obj["email"];
  } else if (obj["value"] instanceof Object && typeof obj["value"]["email"] === "string") {
    email = obj["value"]["email"];
  } else {
    notAuth();
    return;
  }
  return AgentModel.retrieveByEmail(obj["email"]).then(function(agent) {
    return next(null, agent);
  }).fail(function(err) {
    if (err instanceof NotFoundError) {
      notAuth();
      return;
    }
    return next(err);
  });
};

githubEnv = env.getGithubAuth();

passport.use(new GithubStrategy({
  clientID: githubEnv.clientId,
  clientSecret: githubEnv.clientSecret,
  callbackURL: githubEnv.callbackUrl
}, verify));

passportBearer.use(new BearerStrategy(verifyToken));

authenticate = passport.authenticate('github', {
  session: false,
  failureRedirect: '/agent/authenticate/failed'
});

authenticateToken = passportBearer.authenticate('bearer', {
  session: false
});

generateTokenFromAgent = function(agent) {
  var value;
  if (!agent || !(agent instanceof Object)) {
    return "";
  }
  value = null;
  if (agent["getValue"] instanceof Function) {
    value = agent["getValue"]();
  } else if (typeof agent["email"] === "string") {
    value = agent;
  }
  if (!value) {
    return "";
  }
  return jwt.sign(agent, env.getJWTKey());
};

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
  authenticate: authenticateToken,
  authenticateOAuth: authenticate,
  authenticateToken: authenticateToken,
  generateTokenFromAgent: generateTokenFromAgent
};

/*
//# sourceMappingURL=authn.js.map
*/
