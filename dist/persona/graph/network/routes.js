"use strict";

/**
{@link module:joukou-api/persona/graph/network/Model|Network} APIs.

@module joukou-api/persona/graph/network/routes
 */
var GraphModel, JoukouConductorExchange, JoukouConductorRoutingKey, RabbitMQClient, authn, authz, env, self, _;

authn = require('../../../authn');

authz = require('../../../authz');

env = require('../../../env');

GraphModel = require('../model');

_ = require('lodash');

RabbitMQClient = require('joukou-conductor-rabbitmq').RabbitMQClient;

JoukouConductorExchange = process.env["JOUKOU_CONDUCTOR_EXCHANGE"];

JoukouConductorRoutingKey = process.env["JOUKOU_CONDUCTOR_ROUTING_KEY"];

if (!JoukouConductorExchange) {
  JoukouConductorExchange = "amqp://localhost";
  process.env["JOUKOU_CONDUCTOR_EXCHANGE"] = JoukouConductorExchange;
}

if (!JoukouConductorRoutingKey) {
  JoukouConductorRoutingKey = "CONDUCTOR";
  process.env["JOUKOU_CONDUCTOR_ROUTING_KEY"] = JoukouConductorRoutingKey;
}

self = {

  /**
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/graph/:graphKey/network', authn.authenticate, self.retrieve);
    server.post('/persona/:personaKey/graph/:graphKey/network', authn.authenticate, self.update);
    return server.put('/persona/:personaKey/graph/:graphKey/network', authn.authenticate, self.update);
  },
  retrieve: function(req, res, next) {
    return GraphModel.retrieve(req.params.graphKey).then(function(model) {
      return res.send(200, model.getValue().network || {});
    }).fail(next);
  },
  update: function(req, res) {
    return authz.hasGraph(req.user, req.params.graphKey, req.params.personaKey).then(function(_arg) {
      var graph, persona, value;
      graph = _arg.graph, persona = _arg.persona;
      value = graph.getValue();
      value.network = _.assign(value.network || {}, req.body);
      graph.setValue(value.network);
      return graph.save().then(function(graph) {
        var client, host, message;
        client = new RabbitMQClient(JoukouConductorExchange, JoukouConductorRoutingKey);
        host = env.getHost();
        message = {
          '_links': {
            'joukou:graph': {
              href: "" + host + "/persona/" + req.params.personaKey + "/graph/" + req.params.graphKey
            }
          }
        };
        return client.send(message).then(function() {
          return res.send(200, graph.getValue().network);
        });
      });
    }).fail(next);
  }
};

module.exports = self;

/*
//# sourceMappingURL=routes.js.map
*/
