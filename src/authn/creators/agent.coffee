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
