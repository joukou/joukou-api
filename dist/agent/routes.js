"use strict";

/**
{@link module:joukou-api/agent/Model|Agent} routes.

@module joukou-api/agent/routes
@requires lodash
@requires jsonwebtoken
@requires joukou-api/config
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var AgentModel, NotFoundError, UnauthorizedError, authn, authz, config, env, githubEnv, jwt, passport, self, _, _ref;

_ = require('lodash');

jwt = require('jsonwebtoken');

authn = require('../authn');

authz = require('../authz');

config = require('../config');

AgentModel = require('./model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, NotFoundError = _ref.NotFoundError;

env = require('../env');

passport = require('passport');

githubEnv = env.getGithubAuth();

module.exports = self = {

  /**
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.del('/agent', authn.authenticate, self["delete"]);
    server.get('/agent', authn.authenticate, self.index);
    server.post('/agent', self.create);
    server.get('/agent/authenticate', authn.authenticateOAuth, self.authenticate);
    server.get('/agent/authenticate/callback', authn.authenticateOAuth, self.callback);
    server.get('/agent/authenticate/failed', self.failed);
    return server.get('/agent/:agentKey', authn.authenticate, self.retrieve);
  },
  "delete": function(req, res, next) {
    if (!req.user) {
      res.send(503);
      return;
    }
    return req.user["delete"]().then(function() {
      return res.send(204);
    }).fail(next);
  },
  failed: function(req, res) {
    res.header("Location", githubEnv.failedUrl);
    return res.send(302);
  },
  callback: function(req, res, val) {
    var token;
    token = null;
    if (req && req.user) {
      token = authn.generateTokenFromAgent(req.user);
    }
    if (token) {
      res.header("Location", githubEnv.successUrl + "/" + token);
    } else {
      res.header("Location", githubEnv.failedUrl);
    }
    return res.send(302);
  },
  index: function(req, res, next) {
    return res.send(200, req.user.getValue());
  },

  /**
  Handles a request to create an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  create: function(req, res, next) {
    return AgentModel.create(req.body).then(function(agent) {
      return agent.save();
    }).then(function(agent) {
      self = "/agent/" + (agent.getKey());
      res.header('Location', self);
      res.link(self, 'joukou:agent');
      return res.send(201, {});
    }).fail(function(err) {
      return res.send(err);
    });
  },

  /**
  Handles a request to authenticate an agent, and respond with a JSON Web Token
  if successful.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  authenticate: function(req, res, next) {
    var token;
    token = authn.generateTokenFromAgent(req.user);
    res.link("/agent/" + (req.user.getKey()), 'joukou:agent');
    res.link('/persona', 'joukou:personas', {
      title: 'List of Personas'
    });
    return res.send(200, {
      token: token
    });
  },

  /**
  Handles a request to retrieve details about an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  retrieve: function(req, res, next) {
    return AgentModel.retrieve(req.params.agentKey).then(function(agent) {
      if (!(agent.getEmail() === req.user.getEmail() || req.user.hasRole('operator'))) {
        next(new UnauthorizedError());
        return;
      }
      res.link('/persona', 'joukou:personas', {
        title: 'List of Personas'
      });
      return res.send(200, agent.getRepresentation());
    }).fail(function(err) {
      if (err instanceof NotFoundError) {
        return res.send(401);
      } else {
        return next(err);
      }
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
