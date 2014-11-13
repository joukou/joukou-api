# Copyright (C) Fabian Cook - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Fabian Cook <fabian.cook@shipper.co.nz>, 4/ 11 / 14

roboname   = require('roboname')
Q          = require('q')
uuid       = require('node-uuid')
AgentModel = require('../../agent/model')

create = ( persona ) ->
  deferred = Q.defer()

  AgentModel.create(
    email: "#{uuid.v4()}@robot.joukou.com"
    website: "robot.joukou.com"
    name: roboname()
    company: "Robots @ Joukou"
    location: "The cloud"
  )
  .then((agent) ->
    agent.save()
    .then((agent) ->
      value = persona.getValue()

      value.agents = value.agents or []
      value.agents.push(
        {
          key: agent.getKey()
          role: 'robot'
        }
      )

      persona.setValue(value)
      persona.save()
      .then( ->
        deferred.resolve(agent)
      )
    )
  )
  .fail(deferred.reject)
  return deferred.promise

module.exports =
  create: create