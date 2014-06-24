"use strict";

/**
{@link module:joukou-api/persona/graph/process/Model|Process} APIs provide the
ability to inspect and create connections for a graph.

@module joukou-api/persona/graph/process/routes
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
  Registers process-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.index);
    server.post('/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.create);
    server.get('/persona/:personaKey/graph/:graphKey/process/:processKey', authn.authenticate, self.retrieve);
  },

  /**
  @api {get} /persona/:personaKey/graph/:graphKey/process Process index
  @apiName ProcessIndex
  @apiGroup Graph
  
  @apiParam {String} personaKey Personas unique key.
  @apiParam {String} graphKey Graphs unique key.
   */
  index: function(req, res, next) {
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        if (!persona.hasReadPermission(req.user)) {
          throw new UnauthorizedError();
        }
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

  /**
  @api {post} /persona/:personaKey/graph/:graphKey/process
  @apiName AddProcess
  @apiGroup Graph
   */
  create: function(req, res, next) {
    GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var data, document, _ref1, _ref2;
        if (!persona.hasEditPermission(req.user)) {
          throw new UnauthorizedError();
        }
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
            res.header('Location', self);
            return res.send(201, {});
          });
        });
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /**
  @api {get} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName RetrieveProcess
  @apiGroup Graph
   */
  retrieve: function(req, res, next) {
    GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        if (!persona.hasReadPermission(req.user)) {
          throw new UnauthorizedError();
        }
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
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
