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
var AgentModel, authn, authz, config, jwt, self, _;

_ = require('lodash');

jwt = require('jsonwebtoken');

authn = require('../authn');

authz = require('../authz');

config = require('../config');

AgentModel = require('./Model');

module.exports = self = {

  /**
  Register the `/agent` routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.post('/agent', self.create);
    server.post('/agent/authenticate', authn.authenticate, self.authenticate);
    server.get('/agent/:key', authn.authenticate, self.show);
    server.post('/agent/:key/persona', authn.authenticate, self.addPersona);
    server.get('/agent/:key/persona', authn.authenticate, self.personaSearch);
    return server.get('/agent/:key/persona/facet', authn.authenticate, self.personaSearchFacets);
  },

  /**
  Handles a request to create an agent.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  create: function(req, res, next) {
    return AgentModel.create(req.body).then(function(agent) {
      return agent.save().then(function(reply) {
        self = "/agent/" + (reply.getKey());
        res.header('Location', self);
        res.link(self, 'location');
        return res.send(201);
      }).fail(function(err) {
        return res.send(503);
      });
    }).fail(function(err) {
      return res.send(403);
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
    token = jwt.sign(req.user, 'abc', {
      expiresInMinutes: 60 * 5
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
  show: function(req, res, next) {
    return AgentModel.retrieve(req.params.key).then(function(agent) {
      if (!(agent.getEmail() === req.user.getEmail() || req.user.hasRole('operator'))) {
        return res.send(401);
      } else {
        return res.send(200, agent.getRepresentation());
      }
    }).fail(function(err) {
      if (err.notFound) {
        return res.send(401);
      } else {
        return res.send(503);
      }
    });
  },

  /**
  Handles a request to create a relationship between an agent and a persona.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  addPersona: function(req, res, next) {
    return res.send(503);
  },

  /**
  Handles a request to search for relationships between an agent and personas.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  personaSearch: function(req, res, next) {
    return res.send(503);
  },

  /**
  Handles a request to retrieve facets for a search for relationships between
  an agent and personas.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {Function} next
   */
  personaSearchFacets: function(req, res, next) {
    return res.send(503);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
