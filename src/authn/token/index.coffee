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

Q               = require( 'q' )
jwt             = require( 'jsonwebtoken' )
_               = require( 'lodash' )
env             = require( '../../env' )
{ UnauthorizedError, NotFoundError }  = require( 'restify' )
AgentModel      = require( '../../agent/model' )

verify = (token, next) ->
  if not token
    next( new UnauthorizedError() )

  jwt.verify(token, env.getJWTKey(), (err) ->
    if err
      next(new UnauthorizedError() )
      return
    obj = jwt.decode(token)
    if not obj
      next(new UnauthorizedError() )
      return
    if obj not instanceof Object
      next(new UnauthorizedError() )
      return
    if not obj["key"]
      next(new UnauthorizedError() )
      return
    AgentModel
    .retrieve(obj.key)
    .then( ( agent ) ->

      if obj.token
        if agent.getValue().jwt_token isnt obj.token
          next( new UnauthorizedError() )
          return

      next( null, agent )
    )
    .fail( ( err ) ->
      if err instanceof NotFoundError
        next( new UnauthorizedError() )
        return
      next( err )
    )
  )

getValue = (agent) ->
  if not agent
    return
  if agent not instanceof Object
    return
  if agent["getValue"] instanceof Function
    return agent["getValue"]()
  if agent["value"]
    return agent.value

generate = (agent, token = null) ->
  if not agent
    return ""
  if agent not instanceof Object
    return ""
  key = null
  if agent["getKey"] instanceof Function
    key = agent["getKey"]()
  else if agent["key"]
    key = agent["key"]
  if not key
    return ""
  return jwt.sign(
    {
      key: key
      value: not token && getValue(agent)
      token: token
    },
    env.getJWTKey()
  )

module.exports =
  verify: verify
  generate: generate