"use strict";

/**
{@link module:joukou-api/persona/graph/connection/Model|Connection} APIs provide
the ability to inspect and create *Connections* for a *Graph*.

@module joukou-api/persona/graph/connection/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var ForbiddenError, GraphModel, NotFoundError, UnauthorizedError, authn, hal, self, _ref;

authn = require('../../../authn');

hal = require('../../../hal');

GraphModel = require('../Model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, ForbiddenError = _ref.ForbiddenError, NotFoundError = _ref.NotFoundError;

module.exports = self = {

  /**
  Registers connection-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph/:graphKey/connection', authn.authenticate, self.index);
    server.post('/persona/:personaKey/graph/:graphKey/connection', authn.authenticate, self.create);
    server.get('/persona/:personaKey/graph/:graphKey/connection/:connectionKey', authn.authenticate, self.retrieve);
  },
  index: function(req, res, next) {
    return res.send(503);
  },
  create: function(req, res, next) {
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var data, document, process, _i, _len, _ref1;
        if (!persona.hasEditPermission(req.user)) {
          throw new UnauthorizedError();
        }
        data = {};
        data.data = req.body.data;
        data.metadata = req.body.metadata;
        document = hal.parse(req.body, {
          links: {
            'joukou:process': {
              min: 2,
              max: 2,
              match: '/persona/:personaKey/graph/:graphKey/process/:key',
              name: {
                required: true,
                type: 'enum',
                values: ['src', 'tgt']
              }
            }
          }
        });
        _ref1 = document.links['joukou:process'];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          process = _ref1[_i];
          data[process.name] = {
            key: process.key
          };
        }
        return graph.addConnection(data).then(function(connection) {
          return graph.save().then(function() {
            self = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/connection/" + connection.key;
            res.link(self, 'joukou:connection');
            res.header('Location', self);
            return res.send(201, {});
          });
        });
      });
    }).fail(function(err) {
      return next(err);
    });
  },
  retrieve: function(req, res, next) {
    return res.send(503);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
