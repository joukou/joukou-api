"use strict"

###
Authorization.

@module joukou-api/authz
@requires lodash
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

###
@apiDefinePermission guest Unauthenticated users have access.
Anyone with access to the public internet may access these resources.
###

###
@apiDefinePermission agent Agent access rights required.
An *Agent* is authorized to act on behalf of a *Persona* (called the
*Principal*).
###

###
@apiDefinePermission operator Operator access rights required.
An *Operator* is a person that is involved in providing the services of this
Joukou platform installation.
###

_                     = require( 'lodash' )
Q                     = require( 'q' )
PersonaModel          = require( '../persona/model' )
GraphModel            = require( '../persona/graph/model' )
{ UnauthorizedError } = require( 'restify' )

self =
  hasPermission: ( agent, permission ) ->
    throw new Error("Not implemented")
  getRoles: ( agent ) ->
    value = agent.getValue()
    return value.roles or []
  hasRole: ( agent, role ) ->
    return self.getRoles( agent ).indexOf( role ) isnt -1
  hasSomeRoles: ( agent, roles ) ->
    agentRoles = self.getRoles( agent )
    return  _.some( roles, ( role ) ->
      return agentRoles.indexOf( role ) isnt -1
    )
  hasPersona: ( agent, personaKey ) ->
    if (
      not agent or
      not agent.getKey instanceof Function or
      typeof personaKey isnt 'string'
    )
      process.nextTick( ->
        deferred.reject( new UnauthorizedError( 'Agent or persona key not valid' ) )
      )
      return deferred.promise
    deferred = Q.defer()
    PersonaModel.retrieve(personaKey)
    .then( (persona) ->
      value = persona.getValue()
      key = agent.getKey()
      has = _.some(value.agents, (agent) ->
        return agent.key is key
      )
      if has
        deferred.resolve(persona)
      else
        deferred.reject( new UnauthorizedError( 'Persona does not have agent' ) )
    )
    .fail( ->
      deferred.reject( new UnauthorizedError( 'Failed to retrieve persona' ) )
    )
    return deferred.promise
  hasCircle: (agent, circleKey) ->
    deferred = Q.defer()
    PersonaModel.getForAgent(agent.getKey())
    .then( ( personas ) ->
      CircleModel.retrieve(circleKey)
      .then( ( circle ) ->
        keys = _.map(personas, ( persona ) ->
          return persona.getKey()
        )
        has = _.some( circle.personas, ( persona ) ->
          return keys.indexOf( persona.key ) isnt -1
        )
        if has
          deferred.resolve(circle)
        else
          deferred.reject( new UnauthorizedError( 'Cannot access circle' ) )
      )
    )
    .fail( ->
      deferred.reject( new UnauthorizedError( 'Failed to retrieve personas' ) )
    )
    return deferred.promise
  hasGraph: (agent, graphKey, personaKey ) ->
    deferred = Q.defer()
    if typeof graphKey isnt 'string'
      process.nextTick( ->
        deferred.reject( new UnauthorizedError( 'Graph key is not a string' ) )
      )
      return deferred.promise
    self.hasPersona(agent, personaKey)
    .then( (persona) ->
      GraphModel.retrieve(graphKey)
      .then( (graph) ->
        value = graph.getValue()
        key = persona.getKey()
        has = _.some(value.personas, ( persona ) ->
          return persona.key is key
        )
        if has
          deferred.resolve({
            persona: persona
            graph: graph
          })
        else
          deferred.reject( new UnauthorizedError( 'Graph does not have persona' ) )
      )
      .fail( ->
        deferred.reject( new UnauthorizedError( 'Failed to retrieve graph' ) )
      )
    )
    .fail( ->
      deferred.reject( new UnauthorizedError( 'Cannot access persona' ) )
    )
    return deferred.promise



module.exports = self