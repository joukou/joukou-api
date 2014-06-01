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
    return PersonaModel.create(rawValue).then(function(persona) {
      persona.setCreator(req.user);
      persona.setOwner(req.user);
      return persona.save().then(function() {
        res.header('Location', "/persona/" + (persona.getKey()));
        res.link("/persona/" + (persona.getKey()), 'location');
        return res.send(201);
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
