"use strict";

/**
{@link module:joukou-api/persona/graph/model|Graph} APIs provide information about the
graphs that an agent has authorization to access.

@module joukou-api/persona/graph/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var CircleModel, ForbiddenError, GraphModel, GraphStateModel, NotFoundError, PersonaModel, Q, UnauthorizedError, async, authenticate, connection_routes, hal, network_routes, process_routes, request, self, uuid, _, _ref;

_ = require('lodash');

uuid = require('node-uuid');

async = require('async');

authenticate = require('../../authn').authenticate;

hal = require('../../hal');

request = require('request');

connection_routes = require('./connection/routes');

process_routes = require('./process/routes');

network_routes = require('./network/routes');

GraphModel = require('./model');

PersonaModel = require('../model');

CircleModel = require('../../circle/model');

Q = require('q');

GraphStateModel = require('../../agent/graph/state/model');

_ref = require('restify'), UnauthorizedError = _ref.UnauthorizedError, ForbiddenError = _ref.ForbiddenError, NotFoundError = _ref.NotFoundError;

module.exports = self = {

  /**
  Registers graph-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph', authenticate, self.index);
    server.post('/persona/:personaKey/graph', authenticate, self.create);
    server.get('/persona/:personaKey/graph/:graphKey', authenticate, self.retrieve);
    connection_routes.registerRoutes(server);
    process_routes.registerRoutes(server);
    network_routes.registerRoutes(server);
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
          name: graph.name,
          key: graph.key,
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
    }).fail(function(err) {
      if (err instanceof NotFoundError) {
        err = new NotFoundError("Persona '" + req.params.personaKey + "' not found");
      }
      return next(err);
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
        return graph.getConnections().then(function(connections) {
          var item, processPort, promises, representation, setupStateLink, stateDeferred, _i, _len, _ref1;
          representation = {};
          if (req.accepts('application/hal+json')) {
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
            representation._embedded = {
              'joukou:process': _.reduce(graph.getValue().processes || {}, function(memo, process, processKey) {
                memo.push({
                  _links: {
                    self: {
                      href: "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + processKey
                    },
                    'joukou:process-update:position': {
                      href: "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + processKey + "/position"
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
          }
          representation.properties = {
            name: graph.getValue().name,
            metadata: {
              key: req.params.graphKey,
              x: 0,
              y: 0,
              scale: 1
            }
          };
          processPort = function(port) {
            port.process = "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + port.process;
            return port;
          };
          representation.connections = _.map(connections, function(connection) {
            return {
              tgt: processPort(connection.tgt),
              src: processPort(connection.src),
              metadata: {
                key: connection.key
              }
            };
          });
          representation.processes = {};
          representation.outports = {};
          representation.inports = {};
          promises = _.map(graph.getValue().processes, function(process, key) {
            var deferred;
            deferred = Q.defer();
            CircleModel.retrieve(process.circle.key).then(function(circle) {
              var circleValue, mapPort, metadata;
              circleValue = circle.getValue();
              mapPort = function(port) {
                return port;
              };
              metadata = {
                circle: {
                  key: circle.getKey(),
                  value: {
                    description: circleValue.description,
                    icon: circleValue.icon,
                    subgraph: circleValue.subgraph,
                    inports: _.map(circleValue.inports, mapPort),
                    outports: _.map(circleValue.outports, mapPort)
                  }
                },
                key: key,
                image: circleValue.image,
                label: circleValue.name
              };
              metadata = _.merge(metadata, process.metadata);
              representation.processes["/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + key] = {
                id: "/persona/" + (persona.getKey()) + "/graph/" + (graph.getKey()) + "/process/" + key,
                component: circle.getKey(),
                metadata: metadata
              };
              return deferred.resolve();
            }).fail(deferred.reject);
            return deferred.promise;
          });
          stateDeferred = Q.defer();
          setupStateLink = function(state) {
            var link;
            if (!req.accepts("application/hal+json")) {
              return;
            }
            link = "/agent/graph/" + req.params.graphKey + "/state";
            res.link(link, 'joukou:graph:state', {
              title: 'Update graph state'
            });
            return representation._embedded['joukou:graph:state'] = {
              x: state.x,
              y: state.y,
              scale: state.scale,
              metadata: state.metadata || {},
              _links: {
                self: {
                  href: link
                }
              }
            };
          };
          GraphStateModel.retrieveForGraph(req.user.getKey(), req.params.graphKey).then(function(model) {
            var metadata, state;
            state = model.getValue();
            metadata = representation.properties.metadata;
            metadata.x = state.x;
            metadata.y = state.y;
            metadata.scale = state.scale;
            setupStateLink(state);
            return stateDeferred.resolve(model);
          }).fail(function(err) {
            var state;
            state = {
              x: 0,
              y: 0,
              scale: 1
            };
            setupStateLink(state);
            return stateDeferred.resolve(state);
          });
          promises.push(stateDeferred.promise);
          Q.all(promises).then(function() {
            return res.send(200, representation);
          }).fail(function(err) {
            return next(err);
          });
        }).fail(function(err) {
          return next(err);
        });
      }).fail(function(err) {
        return next(err);
      });
    }).fail(function(err) {
      return next(err);
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
