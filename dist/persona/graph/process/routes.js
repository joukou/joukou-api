"use strict";

/**
{@link module:joukou-api/persona/graph/process/Model|Process} APIs provide the
ability to inspect and create *Processes* for a *Graph*.

@module joukou-api/persona/graph/process/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var ForbiddenError, GraphModel, NotFoundError, Q, UnauthorizedError, authn, authz, hal, self, _, _ref;

authn = require('../../../authn');

authz = require('../../../authz');

hal = require('../../../hal');

GraphModel = require('../model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, ForbiddenError = _ref.ForbiddenError, NotFoundError = _ref.NotFoundError;

Q = require('q');

_ = require('lodash');

self = {

  /**
  Registers process-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.index);
    server.post('/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.create);
    server.put('/persona/:personaKey/graph/:graphKey/process/:processKey', authn.authenticate, self.update);
    server.put('/persona/:personaKey/graph/:graphKey/process/:processKey/position', authn.authenticate, self.updatePosition);
    server.get('/persona/:personaKey/graph/:graphKey/process/:processKey', authn.authenticate, self.retrieve);
    server.del('/persona/:personaKey/graph/:graphKey/process/:processKey', authn.authenticate, self.remove);
    server.post('/persona/:personaKey/graph/:graphKey/process/clone', authn.authenticate, self.clone);
  },

  /*
  @api {get} /persona/:personaKey/graph/:graphKey/process List of Processes for a Graph
  @apiName ProcessIndex
  @apiGroup Graph
  @apiParam {String} personaKey Personas unique key.
  @apiParam {String} graphKey Graphs unique key.
   */

  /**
  Handles a request for a list of *Processes* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  index: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var graph, persona;
      graph = _arg.graph, persona = _arg.persona;
      return graph.getProcesses(function(processes) {
        var graphHref, personaHref, representation;
        personaHref = "/persona/" + (persona.getKey());
        res.link(personaHref, 'joukou:persona');
        graphHref = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey());
        res.link(graphHref, 'joukou:graph');
        res.link("" + graphHref + "/process", 'joukou:process-create');
        representation = {};
        representation._embedded = _.reduce(processes, function(process, key) {
          return {
            metadata: process.metadata,
            _links: {
              self: {
                href: "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + key
              },
              'joukou:circle': {
                href: "/persona/" + (persona.getKey()) + "/circle/" + process.circle.key
              },
              'joukou:persona': {
                href: personaHref
              },
              'joukou:graph': {
                href: graphHref
              }
            }
          };
        }, {
          'joukou:process': []
        });
        return res.send(200, representation);
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {post} /persona/:personaKey/graph/:graphKey/process
  @apiName CreateProcess
  @apiGroup Graph
   */

  /**
  Handles a request to create a *Process* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  create: function(req, res, next) {
    authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var data, document, graph, persona, _ref1, _ref2;
      graph = _arg.graph, persona = _arg.persona;
      data = {};
      data.metadata = req.body.metadata;
      document = hal.parse(req.body, {
        links: {
          'joukou:circle': {
            min: 1,
            max: 1,
            match: '/persona/:personaKey/circle/:key'
          }
        }
      });
      if (((_ref1 = document.links['joukou:circle']) != null ? _ref1[0].personaKey : void 0) !== persona.getKey()) {
        throw new ForbiddenError('attempt to use a circle from a different persona');
      }
      data.circle = {
        key: (_ref2 = document.links['joukou:circle']) != null ? _ref2[0].key : void 0
      };
      return graph.addProcess(data).then(function(processKey) {
        return graph.save().then(function() {
          self = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + processKey;
          res.link(self, 'joukou:process');
          res.link("" + self + "/position", 'joukou:process-update:position');
          res.header('Location', self);
          return res.send(201, {});
        });
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {get} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName RetrieveProcess
  @apiGroup Graph
   */

  /**
  Handles a request to retrieve a *Process*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  retrieve: function(req, res, next) {
    authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var graph, persona;
      graph = _arg.graph, persona = _arg.persona;
      return graph.getProcesses().then(function(processes) {
        var process, representation;
        process = processes[req.params.processKey];
        if (!process) {
          throw new NotFoundError();
        }
        representation = {};
        representation.metadata = process.metadata;
        res.link("/persona/" + (persona.getKey()) + "/circle/" + process.circle.key, 'joukou:circle');
        return res.send(200, representation);
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {put} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName UpdateProcess
  @apiGroup Graph
   */

  /**
  Handles a request to update a *Process* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  update: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var data, document, graph, persona, value, _ref1, _ref2;
      graph = _arg.graph, persona = _arg.persona;
      data = {};
      data.metadata = req.body.metadata;
      document = hal.parse(req.body, {
        links: {
          'joukou:circle': {
            min: 1,
            max: 1,
            match: '/persona/:personaKey/circle/:key'
          }
        }
      });
      if (((_ref1 = document.links['joukou:circle']) != null ? _ref1[0].personaKey : void 0) !== persona.getKey()) {
        throw new ForbiddenError('attempt to use a circle from a different persona');
      }
      data.circle = {
        key: (_ref2 = document.links['joukou:circle']) != null ? _ref2[0].key : void 0
      };
      value = graph.getValue();
      value.processes[req.params.processKey] = data;
      graph.setValue(value);
      return graph.save().then(function() {
        self = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + req.params.processKey;
        res.link(self, 'joukou:process');
        res.link("" + self + "/position", 'joukou:process-update:position');
        res.header('Location', self);
        return res.send(200, {});
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {put} /persona/:personaKey/graph/:graphKey/process/:processKey/position
  @apiName UpdateProcessPosition
  @apiGroup Graph
   */

  /**
  Handles a request to update a *Process* position for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  updatePosition: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var graph, persona, process, value;
      graph = _arg.graph, persona = _arg.persona;
      value = graph.getValue();
      process = value.processes[req.params.processKey];
      process.metadata.x = req.body.x;
      process.metadata.y = req.body.y;
      graph.setValue(value);
      return graph.save().then(function() {
        self = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + req.params.processKey;
        res.link(self, 'joukou:process');
        res.link("" + self + "/position", 'joukou:process-update:position');
        res.header('Location', self);
        return res.send(200, {});
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {delete} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName DeleteProcess
  @apiGroup Graph
   */

  /**
  Handles a request to delete a *Process* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  remove: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var graph, persona, value;
      graph = _arg.graph, persona = _arg.persona;
      value = graph.getValue();
      value.processes[req.params.processKey] = void 0;
      graph.setValue(value);
      return graph.save().then(function() {
        return res.send(204, {});
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {post} /persona/:personaKey/graph/:graphKey/process/clone
  @apiName CloneProcess
  @apiGroup Graph
   */

  /**
  Handles a request to clone *Processes* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  clone: function(req, res, next) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var addConnections, connections, edges, graph, nodes, persona, processId, processMap, processPort, processes, promises, shouldReturn;
      graph = _arg.graph, persona = _arg.persona;
      edges = req.body.edges || [];
      nodes = req.body.nodes || [];
      if (nodes.length === 0) {
        return res.send(400);
      }
      shouldReturn = false;
      _.each(edges, function(edge) {
        if (!edge || !edge.from || !edge.from.node || !edge.from.port || !edge.to || !edge.to.node || !edge.to.port) {
          res.send(400, "edge doesn't have the required values");
          shouldReturn = true;
          return false;
        }
      });
      if (shouldReturn) {
        return;
      }
      _.each(nodes, function(node) {
        if (!node || !node.component || !node.id || !node.metadata || !node.metadata.key || !node.metadata.circle || !node.metadata.circle.key || !node.metadata.circle.value) {
          res.send(400, "node doesn't have the required values");
          shouldReturn = true;
          return false;
        }
      });
      if (shouldReturn) {
        return;
      }
      processes = {};
      connections = [];
      processMap = {};
      promises = _.map(nodes, function(node) {
        var circle, deferred, metadata;
        deferred = Q.defer();
        circle = {
          key: node.metadata.circle.key
        };
        metadata = {
          x: node.metadata.x,
          y: node.metadata.y
        };
        graph.addProcess({
          circle: circle,
          metadata: metadata
        }).then(function(key) {
          processMap[node.id] = key;
          processes[key] = {
            id: processId(key),
            component: circle.key,
            metadata: {
              nodeId: node.id,
              x: metadata.x,
              y: metadata.y,
              circle: circle.key,
              key: key
            }
          };
          return deferred.resolve(key);
        }).fail(deferred.reject);
        return deferred.promise;
      });
      processId = function(key) {
        return "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + key;
      };
      processPort = function(port) {
        port.process = processId(port.process);
        return port;
      };
      addConnections = function() {
        var connectionPromises;
        connectionPromises = _.map(edges, function(edge) {
          var data, deferred;
          data = {};
          data.metadata = {};
          data.src = {
            process: processMap[edge.from.node] || edge.from.node,
            port: edge.from.port,
            metadata: {}
          };
          data.tgt = {
            process: processMap[edge.to.node] || edge.to.node,
            port: edge.to.port,
            metadata: {}
          };
          deferred = Q.defer();
          graph.addConnection(data).then(function(connection) {
            data = _.cloneDeep(data);
            data.metadata.key = connection.key;
            data.src = processPort(data.src);
            data.tgt = processPort(data.tgt);
            connections.push(data);
            return deferred.resolve(connection);
          }).fail(deferred.reject);
          return deferred.promise;
        });
        return Q.all(connectionPromises).then(function() {
          return graph.save().then(function() {
            return res.send(200, {
              processes: processes,
              connections: connections
            });
          });
        });
      };
      return Q.all(promises).then(addConnections).fail(function(error) {
        return res.send(400, error);
      });
    }).fail(function(err) {
      return next(err);
    });
  }
};

module.exports = self;

/*
//# sourceMappingURL=routes.js.map
*/
