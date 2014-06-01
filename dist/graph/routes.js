"use strict";

/**
{@link module:joukou-api/graph/model|Graph} APIs provide information about the
graphs that an agent has authorization to access.

At this time graph APIs are read-only and all write operations are performed via
the `joukou-fbpp` WebSocket flow-based programming protocol server.

@module joukou-api/graph/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var GraphModel, authn, self;

authn = require('../authn');

GraphModel = require('./Model');

module.exports = self = {

  /**
  Registers graph-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph', authn.authenticate, self.search);
    server.post('/graph', authn.authenticate, self.create);
    return server.get('/graph/:graphKey', authn.authenticate, self.retrieve);
  },

  /*
  @api {post} /graph Creates a new Joukou graph
  @apiName CreateGraph
  @apiGroup Graph
  
  @apiParam {Object.<String, String>} properties
  @apiParam {Object.<String, !Object>} processes
  @apiParam {Array.<Object>} connections
  
  @apiExample CURL Example:
    curl -i -X POST https://api.joukou.com/graph \
      -H 'Content-Type: application/json' \
      -d '{ "properties": { "name": "MySQL to REST API" }, "processes": { "Query Database": { "component": "MySQLQuery", "metadata": { ... } }, "Publish REST API": { "component": "RestfulAPIEndpoint", "metadata": { ... } } }, "connections": [ { "src": { "process": "Query Database", "port": "out" }, "tgt": { process: "Publish REST API", "port": "in" } } ] }'
  
  @apiSuccess (201) Created The graph has been created successfully.
  
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure creating the graph, the client should try again later.
   */
  create: function(req, res, next) {
    var rawValue;
    rawValue = req.body;
    console.log(req.user);
    rawValue.persona = req.user.username;
    return GraphModel.create(rawValue).then(function(graph) {
      res.link("/graph/" + (graph.getMetaValue().getKey()), 'location');
      return res.send(201);
    }).fail(function(err) {
      return res.send(503);
    });
  },

  /*
  @api {get} /graph/:key Retrieve the definition of a Joukou graph
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
    return GraphModel.retrieve(req.params.graphKey).then(function(graph) {
      console.log(req.user);
      return res.send(graph.getValue());
    }).fail(function(err) {
      if (err.notFound) {
        return res.send(404);
      } else {
        return res.send(503);
      }
    });
  },

  /**
  Handles a request to search for graphs owned by a certain persona.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  search: function(req, res, next) {
    return res.send(503);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
