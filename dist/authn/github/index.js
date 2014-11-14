var Agent, AgentModel, GithubStrategy, NotFoundError, Q, UnauthorizedError, create, env, githubEnv, putAgent, verify, _, _ref;

Q = require('q');

env = require('../../env');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

githubEnv = env.getGithubAuth();

AgentModel = require('../../agent/model');

_ = require('lodash');

Agent = require('../creators/agent');

GithubStrategy = require('passport-github').Strategy;

create = function(profile, accessToken, refreshToken, agent) {
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
    location: profile.location,
    github_token: accessToken,
    github_refresh_token: refreshToken
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

putAgent = function(profile, accessToken, refreshToken, agent, next) {
  return create(profile, accessToken, refreshToken, agent).then(function(agent) {
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
    promise = AgentModel.search("email:" + profile.email, true);
  } else if (profile.id) {
    promise = AgentModel.search("github_id:" + profile.id, true);
  } else {
    next(new UnauthorizedError());
    return;
  }
  return promise.then(function(agent) {
    return putAgent(profile, accessToken, refreshToken, agent, next);
  }).fail(function(err) {
    if (!(err instanceof NotFoundError)) {
      next(err);
      return;
    }
    return putAgent(profile, accessToken, refreshToken, null, next);
  });
};

module.exports = {
  authenticate: null,
  Strategy: null,
  setup: function(passport) {
    passport.use(this.Strategy = new GithubStrategy({
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
