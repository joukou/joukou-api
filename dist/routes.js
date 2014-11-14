"use strict";

/**
@module joukou-api/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@author Juan Morales <juan@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var agent, contact, github, persona, runtime, self;

agent = require('./agent/routes');

contact = require('./contact/routes');

persona = require('./persona/routes');

runtime = require('./runtime/routes');

github = require('./github/routes');

module.exports = self = {

  /**
  Registers all routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    agent.registerRoutes(server);
    contact.registerRoutes(server);
    persona.registerRoutes(server);
    runtime.registerRoutes(server);
    github.registerRoutes(server);
    return server.get('/', self.index);
  },

  /*
  @api {get} / Joukou API entry point.
  @apiName EntryPoint
  @apiGroup Joukou
   */
  index: function(req, res, next) {
    res.link('/agent', 'joukou:agent-create', {
      title: 'Create an Agent'
    });
    res.link('/agent/authenticate', 'joukou:agent-authn', {
      title: 'Authenticate'
    });
    res.link('/contact', 'joukou:contact', {
      title: 'Send a Message to Joukou'
    });
    return res.send(200, {});
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
