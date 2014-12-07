"use strict";

/**
{@link module:joukou-api/persona/graph/connection/Model|Connection} APIs provide
the ability to inspect and create *Connections* for a *Graph*.

@module joukou-api/persona/graph/connection/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var ConnectionSchema, ForbiddenError, GraphModel, NotFoundError, UnauthorizedError, authn, hal, self, _, _ref;

authn = require('../../../authn');

hal = require('../../../hal');

GraphModel = require('../model');

ConnectionSchema = require('./schema');

_ = require('lodash');

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
    server.del('/persona/:personaKey/graph/:graphKey/connection/:connectionKey', authn.authenticate, self.remove);
  },

  /*
  @api {get} /persona/:personaKey/graph/:graphKey/connection List of Connections for a Graph
  @apiName ConnectionIndex
  @apiGroup Graph
  @apiParam {String} personaKey Persona's unique key
  @apiParam {String} graphKey Graph's unique key
   */

  /**
  Handles a request for a list of *Connections* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  index: function(req, res, next) {
    authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var graph, persona;
      graph = _arg.graph, persona = _arg.persona;
      return graph.getConnections(function(connections) {
        return res.send(200, connections.getRepresentation());
      });
    }).fail(function(err) {
      return next(err);
    });
  },
  create: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var data, document, graph, persona, process, _i, _len, _ref1;
      graph = _arg.graph, persona = _arg.persona;
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
            },
            properties: {
              port: {
                required: true,
                type: 'string'
              },
              matadata: {
                required: false,
                type: 'object'
              }
            }
          }
        }
      });
      _ref1 = document.links['joukou:process'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        process = _ref1[_i];
        data[process.name] = {
          process: process.key,
          port: process.port,
          metadata: process.metadata || {}
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
    }).fail(function(err) {
      return next(err);
    });
  },
  retrieve: function(req, res, next) {
    return res.send(503);
  },

  /*
  @api {delete} /persona/:personaKey/graph/:graphKey/connection/:connectionKey Remove connection from a grapg
  @apiName ConnectionRemove
  @apiGroup Graph
  @apiParam {String} personaKey Persona's unique key
  @apiParam {String} graphKey Graph's unique key
  @apiParam {String} connectionKey Connection's unique key
   */

  /**
  Handles a request for removing a *Connections* from a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  remove: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var connections, graph, persona, value;
      graph = _arg.graph, persona = _arg.persona;
      value = graph.getValue();
      connections = value.connections || (value.connections = []);
      _.remove(connections, function(connection) {
        return connection.key === req.params.connectionKey;
      });
      graph.setValue(value);
      return graph.save().then(function() {
        return res.send(204);
      });
    }).fail(function(err) {
      return next(err);
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
