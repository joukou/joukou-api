"use strict";

/**
{@link module:joukou-api/persona/graph/process/Model|Process} APIs provide the
ability to inspect and create *Processes* for a *Graph*.

@module joukou-api/persona/graph/process/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var ForbiddenError, GraphModel, NotFoundError, UnauthorizedError, authn, hal, self, _ref;

authn = require('../../../authn');

hal = require('../../../hal');

GraphModel = require('../model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, ForbiddenError = _ref.ForbiddenError, NotFoundError = _ref.NotFoundError;

module.exports = self = {

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
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
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
    GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var data, document, _ref1, _ref2;
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
    GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
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
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var data, document, value, _ref1, _ref2;
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
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var process, value;
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
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var value;
        value = graph.getValue();
        value.processes[req.params.processKey] = void 0;
        graph.setValue(value);
        return graph.save().then(function() {
          return res.send(204, {});
        });
      });
    }).fail(function(err) {
      return next(err);
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
