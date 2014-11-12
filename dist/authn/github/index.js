var Agent, AgentModel, GithubStrategy, NotFoundError, Q, UnauthorizedError, create, env, githubEnv, putAgent, verify, _, _ref;

Q = require('q');

env = require('../../env');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

githubEnv = env.getGithubAuth();

AgentModel = require('../../agent/model');

_ = require('lodash');

Agent = require('../creators/agent');

GithubStrategy = require('passport-github').Strategy;

create = function(profile, agent) {
  var deferred, value, values;
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
  values = {
    email: profile.email,
    github_login: profile.login,
    github_id: profile.id,
    image_url: profile.avatar_url,
    website: profile.blog,
    github_url: profile.url,
    name: profile.name,
    company: profile.company,
    location: profile.location
  };
  if (agent) {
    value = agent.getValue() || {};
    _.assign(value, values);
    agent.setValue(value);
    agent.save().then(deferred.resolve).fail(deferred.reject);
  } else {
    Agent.create(values).then(deferred.resolve).fail(deferred.reject);
  }
  return deferred.promise;
};

putAgent = function(profile, agent, next) {
  return create(profile, agent).then(function(agent) {
    return next(null, agent);
  }).fail(function(err) {
    return next(err);
  });
};

verify = function(accessToken, refreshToken, profile, next) {
  var promise;
  profile = profile || {};
  if (!profile) {
    next(new UnauthorizedError());
    return;
  }
  promise = null;
  if (profile.email) {
    promise = AgentModel.retrieveByEmail(profile.email);
  } else if (profile.id) {
    promise = AgentModel.retriveByGithubId(profile.id);
  } else {
    next(new UnauthorizedError());
    return;
  }
  return promise.then(function(agent) {
    return putAgent(profile, agent, next);
  }).fail(function(err) {
    if (!(err instanceof NotFoundError)) {
      next(err);
      return;
    }
    return putAgent(profile, null, next);
  });
};

module.exports = {
  authenticate: null,
  setup: function(passport) {
    passport.use(new GithubStrategy({
      clientID: githubEnv.clientId,
      clientSecret: githubEnv.clientSecret,
      callbackURL: githubEnv.callbackUrl,
      scope: githubEnv.scope
    }, verify));
    return this.authenticate = passport.authenticate('github', {
      session: false,
      failureRedirect: '/agent/authenticate/failed'
    });
  }
};

/*
//# sourceMappingURL=index.js.map
*/
