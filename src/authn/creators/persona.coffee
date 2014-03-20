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

Q             = require('q')
PersonaModel  = require( '../../persona/model' )
Circles       = require( './circles' )
Graph         = require( './graph' )

postCreate = ( persona ) ->
  return Q.all([
    Graph.create( persona )
    Circles.create( persona )
  ])

create = ( name = "Default Persona", agents = [] ) ->
  deferred = Q.defer()
  PersonaModel.create(
    name: name
    agents: agents
  )
    .then( ( persona ) ->
      persona.save()
        .then( ->
          postCreate(persona)
            .then( ->
              deferred.resolve(persona)
            )
        )
    )
    .fail(deferred.reject)

  return deferred.promise


module.exports =
  create: create