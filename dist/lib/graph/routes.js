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
var authn, self;

authn = require('../authn');

module.exports = self = {

  /**
  Registers graph-related routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    return server.get('/persona/:personaKey/graph', authn.authenticate, self.search);
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
