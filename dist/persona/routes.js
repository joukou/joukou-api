"use strict";

/**
{@link module:joukou-api/personas/Model|Persona} routes.

@module joukou-api/persona/routes
@requires lodash
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/persona/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var PersonaModel, authn, authz, self, _;

_ = require('lodash');

authn = require('../authn');

authz = require('../authz');

PersonaModel = require('./Model');

module.exports = self = {

  /**
  Register `/persona` routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.post('/persona', authn.authenticate, self.create);
    server.get('/persona/:personaKey', authn.authenticate, self.show);
  },

  /**
  Handles a request to create a new *persona*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  create: function(req, res, next) {
    console.log(require('util').inspect(req.body));
    return PersonaModel.create(req.body).then(function(persona) {
      return persona.save().then(function(reply) {
        self = "/persona/" + (persona.getKey());
        res.header('Location', self);
        res.link(self, 'location');
        return res.send(201);
      }).fail(function(err) {
        return res.send(503);
      });
    }).fail(function(err) {
      return res.send(503);
    });
  },

  /**
  Handles a request to retrieve a certain *persona's* details.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  show: function(req, res, next) {
    return res.send(503);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
