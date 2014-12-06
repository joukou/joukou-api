"use strict"

###*
{@link module:joukou-api/persona/graph/network/Model|Network} APIs.

@module joukou-api/persona/graph/network/routes
###

authn              = require( '../../../authn' )
env                = require( '../../../env' )
GraphModel         = require( '../model' )
_                  = require( 'lodash' )
{ RabbitMQClient } = require( 'joukou-conductor-rabbitmq' )

JoukouConductorExchange   = process.env["JOUKOU_CONDUCTOR_EXCHANGE"]
JoukouConductorRoutingKey = process.env["JOUKOU_CONDUCTOR_ROUTING_KEY"]

# https://github.com/joukou/joukou-conductor-rabbitmq/blob/develop/src/lib/conductor-client.coffee#L13
if not JoukouConductorExchange
  JoukouConductorExchange = "amqp://localhost"
  process.env["JOUKOU_CONDUCTOR_EXCHANGE"] = JoukouConductorExchange

if not JoukouConductorRoutingKey
  JoukouConductorRoutingKey = "CONDUCTOR"
  process.env["JOUKOU_CONDUCTOR_ROUTING_KEY"] = JoukouConductorRoutingKey

self =
  ###*
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(
      '/persona/:personaKey/graph/:graphKey/network',
      authn.authenticate, self.index
    )
    server.post(
      '/persona/:personaKey/graph/:graphKey/network',
      authn.authenticate, self.index
    )
    server.put(
      '/persona/:personaKey/graph/:graphKey/network',
      authn.authenticate, self.index
    )

  retrieve: (req, res, next) ->
    GraphModel.retrieve(req.params.graphKey)
    .then( (model) ->
      res.send(200, model.getValue().network or {})
    )
    .fail(next)

  update: (req, res) ->
    GraphModel.retrieve(req.params.graphKey)
    .then( (model) ->
      value = model.getValue()
      value.network = _.assign(value.network or {}, req.body)
      model.setValue(value.network)
      model.save()
      .then((model) ->
        client = new RabbitMQClient(
          JoukouConductorExchange,
          JoukouConductorRoutingKey
        )
        host = env.getHost()
        message = {
          '_links': {
            'joukou:graph': {
              #TODO change host to env
              href: "#{host}/persona/#{req.params.personaKey}/graph/#{req.params.graphKey}"
            }
          }
        }
        client.send(
          message
        )
        .then( ->
          res.send(200, model.getValue().network)
        )
      )
    )
    .fail(next)



module.exports = self