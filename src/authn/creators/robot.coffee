###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

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