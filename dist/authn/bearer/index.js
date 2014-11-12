var AgentModel, BearerStrategy, NotFoundError, Q, UnauthorizedError, env, generate, getValue, jwt, verify, _, _ref;

BearerStrategy = require('passport-http-bearer').Strategy;

Q = require('q');

jwt = require('jsonwebtoken');

_ = require('lodash');

env = require('../../env');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

AgentModel = require('../../agent/model');

verify = function(token, next) {
  if (!token) {
    next(new UnauthorizedError());
  }
  return jwt.verify(token, env.getJWTKey(), function(err) {
    var obj;
    if (err) {
      next(new UnauthorizedError());
      return;
    }
    obj = jwt.decode(token);
    if (!obj) {
      next(new UnauthorizedError());
      return;
    }
    if (!(obj instanceof Object)) {
      next(new UnauthorizedError());
      return;
    }
    if (!obj["key"]) {
      next(new UnauthorizedError());
      return;
    }
    return AgentModel.retrieve(obj.key).then(function(agent) {
      return next(null, agent);
    }).fail(function(err) {
      if (err instanceof NotFoundError) {
        next(new UnauthorizedError());
        return;
      }
      return next(err);
    });
  });
};

getValue = function(agent) {
  if (!agent) {
    return;
  }
  if (!(agent instanceof Object)) {
    return;
  }
  if (agent["getValue"] instanceof Function) {
    return agent["getValue"]();
  }
  if (agent["value"]) {
    return agent.value;
  }
};

generate = function(agent) {
  var key;
  if (!agent) {
    return "";
  }
  if (!(agent instanceof Object)) {
    return "";
  }
  key = null;
  if (agent["getKey"] instanceof Function) {
    key = agent["getKey"]();
  } else if (agent["key"]) {
    key = agent["key"];
  }
  if (!key) {
    return "";
  }
  return jwt.sign({
    key: key,
    value: getValue(agent)
  }, env.getJWTKey());
};

module.exports = {
  authenticate: null,
  generate: generate,
  setup: function(passport) {
    passport.use(new BearerStrategy(verify));
    return this.authenticate = passport.authenticate('bearer', {
      session: false
    });
  }
};

/*
//# sourceMappingURL=index.js.map
*/
