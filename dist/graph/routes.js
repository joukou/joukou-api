"use strict";

/**
{@link module:joukou-api/graph/model|Graph} APIs provide information about the
graphs that an agent has authorization to access.

@module joukou-api/graph/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var ForbiddenError, GraphModel, NotFoundError, PersonaModel, UnauthorizedError, async, authn, hal, request, self, uuid, _, _ref;

_ = require('lodash');

uuid = require('node-uuid');

async = require('async');

authn = require('../authn');

hal = require('../hal');

request = require('request');

GraphModel = require('./Model');

PersonaModel = require('../persona/Model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, ForbiddenError = _ref.ForbiddenError, NotFoundError = _ref.NotFoundError;

module.exports = self = {

  /**
  Registers graph-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph', authn.authenticate, self.index);
    server.post('/persona/:personaKey/graph', authn.authenticate, self.create);
    server.get('/persona/:personaKey/graph/:graphKey', authn.authenticate, self.retrieve);
    server.get('/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.processIndex);
    server.post('/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.addProcess);
    server.get('/persona/:personaKey/graph/:graphKey/process/:processKey', authn.authenticate, self.retrieveProcess);
    server.get('/persona/:personaKey/graph/:graphKey/connection', authn.authenticate, self.connectionIndex);
    server.post('/persona/:personaKey/graph/:graphKey/connection', authn.authenticate, self.addConnection);
  },

  /**
  Handles a request to search for graphs owned by a certain persona.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  index: function(req, res, next) {
    request({
      uri: 'http://localhost:8098/mapred',
      method: 'POST',
      json: {
        inputs: {
          module: 'yokozuna',
          "function": 'mapred_search',
          arg: ['graph', 'personas.key:' + req.params.personaKey]
        },
        query: [
          {
            map: {
              language: 'javascript',
              keep: true,
              source: (function(value, keyData, arg) {
                var result;
                result = Riak.mapValuesJson(value)[0];
                result.key = value.key;
                return [result];
              }).toString()
            }
          }
        ]
      }
    }, function(err, reply) {
      var representation;
      if (err) {
        res.send(503);
        return;
      }
      representation = {};
      representation._embedded = _.reduce(reply.body, function(memo, graph) {
        memo['joukou:graph'].push({
          _links: {
            self: {
              href: "/persona/" + req.params.personaKey + "/graph/" + graph.key
            },
            'joukou:persona': {
              href: "/persona/" + req.params.personaKey
            },
            'joukou:process-create': {
              href: "/persona/" + req.params.personaKey + "/graph/" + graph.key + "/process"
            },
            'joukou:processes': {
              href: "/persona/" + req.params.personaKey + "/graph/" + graph.key + "/process"
            },
            'joukou:connection-create': {
              href: "/persona/" + req.params.personaKey + "/graph/" + graph.key + "/connection"
            },
            'joukou:connections': {
              href: "/persona/" + req.params.personaKey + "/graph/" + graph.key + "/connection"
            }
          }
        });
        return memo;
      }, {
        'joukou:graph': []
      });
      res.link("/persona/" + req.params.personaKey, 'joukou:persona');
      res.send(200, representation);
    });
  },

  /*
  @api {post} /persona/:personaKey/graph Creates a Joukou graph
  @apiName CreateGraph
  @apiGroup Graph
  
  @apiParam {Object} properties
  
  @apiExample CURL Example:
    curl -i -X POST https://api.joukou.com/persona/7bcb937e-3938-49c5-a1ce-5eb45f194f2f/graph \
      -H 'Content-Type: application/json' \
      -d '{ "name": "CRM to Sharepoint Integration" }'
  
  @apiSuccess (201) Created The graph has been created successfully.
  
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure creating the graph, the client should try again later.
   */
  create: function(req, res, next) {
    return PersonaModel.retrieve(req.params.personaKey).then(function(persona) {
      var data;
      if (!persona.hasEditPermission(req.user)) {
        next(new UnauthorizedError());
        return;
      }
      data = {};
      data.name = req.body.name;
      data.personas = [
        {
          key: persona.getKey()
        }
      ];
      return GraphModel.create(data).then(function(graph) {
        return graph.save();
      }).then(function(graph) {
        self = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey());
        res.link(self, 'joukou:graph');
        res.header('Location', self);
        return res.send(201, {});
      }).fail(function(err) {
        return next(err);
      });
    });
  },

  /*
  @api {get} /graph/:graphKey Retrieve the definition of a Joukou graph
  @apiName RetrieveGraph
  @apiGroup Graph
  
  @apiExample CURL Example:
    curl -i -X GET https://api.joukou.com/graph/15269bc7-a6b2-42c5-8805-879f1fe11ec0
  
  @apiSuccess (200) OK The graph definition is sent in the response.
  
  @apiError (401) Unauthorized The request requires user authentication, or authorization has been refused for the supplied credentials.
  @apiError (404) NotFound The server did not find a graph definition that matched the provided key.
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure retrieving the graph definition, the client should try again later.
   */
  retrieve: function(req, res, next) {
    GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        var item, representation, _i, _len, _ref1;
        if (!persona.hasReadPermission(req.user)) {
          next(new UnauthorizedError());
          return;
        }
        _ref1 = graph.getValue().personas;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          item = _ref1[_i];
          res.link("/persona/" + item.key, 'joukou:persona');
        }
        res.link("/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process", 'joukou:process-create', {
          title: 'Add a Process to this Graph'
        });
        res.link("/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process", 'joukou:processes', {
          title: 'List of Processes for this Graph'
        });
        res.link("/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/connection", 'joukou:connection-create', {
          title: 'Add a Connection to this Graph'
        });
        res.link("/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/connection", 'joukou:connections', {
          title: 'List of Connections for this Graph'
        });
        representation = _.pick(graph.getValue(), ['name']);
        representation._embedded = {
          'joukou:process': _.reduce(graph.getValue().processes || {}, function(memo, process, processKey) {
            memo.push({
              _links: {
                self: {
                  href: "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + processKey
                }
              },
              metadata: process.metadata
            });
            return memo;
          }, []),
          'joukou:connection': _.reduce(graph.getValue().connections || [], function(memo, connection, i) {
            memo.push({
              _links: {
                self: {
                  href: "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/connection/" + connection.key
                },
                'joukou:process': [
                  {
                    name: 'src'
                  }, {
                    name: 'tgt'
                  }
                ]
              }
            });
            return memo;
          }, [])
        };
        res.send(200, representation);
      });
    }).fail(function(err) {
      return next(err);
    });
  },
  processIndex: function(req, res, next) {
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
  addProcess: function(req, res, next) {
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
  retrieveProcess: function(req, res, next) {
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
  },
  connectionIndex: function(req, res, next) {
    return res.send(503);
  },
  addConnection: function(req, res, next) {
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      return graph.getPersona().then(function(persona) {
        if (!persona.hasEditPermission(req.user)) {
          throw new UnauthorizedError();
        }
        return graph.addConnection(req.body).then(function(connection) {
          return res.send(503);
        });
      }).fail(function(err) {
        return next(err);
      });
    }).fail(function(err) {
      return next(err);
    });
  },
  retrieveConnection: function(req, res, next) {
    return res.send(503);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
