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
var AgentModel, BearerStrategy, GithubStrategy, GraphModel, NotFoundError, PersonaModel, Q, UnauthorizedError, authenticate, authenticateToken, env, generateTokenFromAgent, githubEnv, githubProfileToAgent, jwt, passport, passportBearer, self, verify, verifyToken, _, _ref;

passport = require('passport');

passportBearer = require('passport');

GithubStrategy = require('passport-github').Strategy;

AgentModel = require('./agent/Model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

env = require('./env');

Q = require('q');

BearerStrategy = require('passport-http-bearer').Strategy;

jwt = require('jsonwebtoken');

_ = require('lodash');

PersonaModel = require('./Persona/Model');

GraphModel = require('./Persona/Graph/Model');

githubProfileToAgent = function(profile, agent) {
  var afterCreation, created, creating, deferred;
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
  creating = false;
  afterCreation = function(actualAgent) {
    var afterDeferred, createdPersona;
    afterDeferred = Q.defer();
    createdPersona = function(persona) {
      var data;
      data = {};
      data.name = "Default graph";
      data.personas = [
        {
          key: persona.getKey()
        }
      ];
      return GraphModel.create(data).then(function(graph) {
        return graph.save();
      }).then(function() {
        return afterDeferred.resolve();
      }).fail(afterDeferred.reject);
    };
    PersonaModel.create({
      name: "Default persona",
      agents: [
        {
          key: actualAgent.getKey(),
          role: 'creator'
        }
      ]
    }).then(function(persona) {
      return persona.save().then(function() {
        return createdPersona(persona);
      }).fail(afterDeferred.reject);
    }).fail(afterDeferred.reject);
    return afterDeferred.promise;
  };
  created = function(actualAgent) {
    var value;
    value = actualAgent.getValue() || {};
    _.assign(value, {
      email: profile.email,
      github_login: profile.login,
      github_id: profile.id,
      image_url: profile.avatar_url,
      website: profile.blog,
      github_url: profile.url,
      name: profile.name,
      company: profile.company,
      location: profile.location
    });
    actualAgent.setValue(value);
    actualAgent.save().then(function(agent) {
      if (!creating) {
        deferred.resolve(actualAgent);
        return;
      }
      return afterCreation(actualAgent).then(function() {
        return deferred.resolve(actualAgent);
      }).fail(deferred.reject);
    }).fail(function(err) {
      return deferred.reject(err);
    });
    return void 0;
  };
  if (agent) {
    created(agent);
  } else {
    creating = true;
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
  var promise, saveOrCreate;
  saveOrCreate = function(agent) {
    return githubProfileToAgent(profile, agent).then(function(agent) {
      return next(null, agent);
    }).fail(function(err) {
      return next(err);
    });
  };
  promise = null;
  profile = profile || {};
  profile = profile._json || profile;
  if (!profile) {
    next(new UnauthorizedError());
    return;
  }
  if (profile.email) {
    promise = AgentModel.retrieveByEmail(profile.email);
  } else {
    promise = AgentModel.retriveByGithubId(profile.id);
  }
  return promise.then(function(agent) {
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
  var notAuth;
  notAuth = function() {
    return next(new UnauthorizedError());
  };
  return jwt.verify(token, env.getJWTKey(), function(err, obj) {
    if (err) {
      notAuth();
      return;
    }
    obj = jwt.decode(token);
    if (!obj || !(obj instanceof Object)) {
      notAuth();
      return;
    }
    if (!obj["email"]) {
      notAuth();
      return;
    }
    return AgentModel.retrieveByEmail(obj["email"]).then(function(agent) {
      return next(null, agent);
    }).fail(function(err) {
      if (err instanceof NotFoundError) {
        console.log(obj["email"]);
        notAuth();
        return;
      }
      return next(err);
    });
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
  } else {
    value = agent;
  }
  if (!value) {
    return "";
  }
  return jwt.sign(value, env.getJWTKey());
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
