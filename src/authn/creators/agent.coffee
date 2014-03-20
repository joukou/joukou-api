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

Q           = require( 'q' )
Persona     = require( './persona' )
AgentModel  = require( '../../agent/model' )

setupPersona = ( agent ) ->
  Persona.create(
    "Default Persona",
    [
      {
        key: agent.getKey()
        role: 'creator'
      }
    ]
  )

create = ( value ) ->
  deferred = Q.defer()

  AgentModel.create(
    value
  )
    .then( (agent) ->
      agent.save()
        .then(->
          setupPersona(agent)
            .then(->
              deferred.resolve(agent)
            )
        )
    ).fail(deferred.reject)
  return deferred.promise

module.exports =
  create: create
