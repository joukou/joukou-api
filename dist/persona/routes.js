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
    server.get('/persona/:key', authn.authenticate, self.retrieve);
  },

  /*
  @api {post} /persona Create a new Joukou Persona
  @apiName Persona
  @apiGroup Persona
  
  @apiParam {String} name The name of the Persona
  
  @apiExample CURL Example:
    curl -i -X POST https://api.joukou.com/persona \
      -H 'Content-Type: application/json' \
      -d '{ "name": "Joukou Ltd" }'
  
  @apiSuccess (201) Created The Persona has been created successfully.
  
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  
  @apiError (503) ServiceUnavailable There was a temporary failure creating the Persona, the client should try again later.
   */

  /**
  Handles a request to create a new *persona*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  create: function(req, res, next) {
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

  /*
  @api {get} /persona/:key Retrieve a Joukou Persona
  @apiName Persona
  @apiGroup Persona
   */

  /**
  Handles a request to retrieve a certain *persona's* details.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  retrieve: function(req, res, next) {
    return PersonaModel.retrieve(req.params.key).then(function(persona) {
      return res.send(200, persona.getValue());
    }).fail(function(err) {
      if (err.notFound) {
        return res.send(404);
      } else {
        return res.send(503);
      }
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
