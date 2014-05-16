"use strict";

/**
@module joukou-api/routes
@author Juan Morales <juan@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var agent, contact, graph, network, persona, runtime;

agent = require('./agent/routes');

contact = require('./contact/routes');

graph = require('./graph/routes');

network = require('./network/routes');

persona = require('./persona/routes');

runtime = require('./runtime/routes');

module.exports = {

  /**
  Registers all routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    agent.registerRoutes(server);
    contact.registerRoutes(server);
    graph.registerRoutes(server);
    network.registerRoutes(server);
    persona.registerRoutes(server);
    return runtime.registerRoutes(server);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
