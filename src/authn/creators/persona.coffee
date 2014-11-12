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