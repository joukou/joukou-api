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

Q              = require( 'q' )
env            = require( '../../env' )
{ UnauthorizedError, NotFoundError } = require( 'restify' )
githubEnv      = env.getGithubAuth()
AgentModel     = require( '../../agent/model' )
_              = require( 'lodash' )
Agent          = require( '../creators/agent' )
GithubStrategy = require( 'passport-github' ).Strategy


create = ( profile, accessToken, refreshToken, agent ) ->
  deferred = Q.defer()

  profile = profile._json or profile

  if not profile
    deferred.reject(new Error("Profile not provided"))
    return
  if not profile.email or not profile.id or not profile.name
    deferred.reject(new Error("Required details not provided"))
    return

  values =
    email: profile.email
    github_login: profile.login
    github_id: profile.id
    image_url: profile.avatar_url
    website: profile.blog
    github_url: profile.url
    name: profile.name
    company: profile.company
    location: profile.location
    github_token: accessToken
    github_refresh_token: refreshToken

  if agent
    value = agent.getValue() or {}
    _.assign(value, values)
    agent.setValue(value)
    agent.save()
      .then(deferred.resolve)
      .fail(deferred.reject)
  else
    Agent.create(values)
      .then(deferred.resolve)
      .fail(deferred.reject)

  return deferred.promise

putAgent = ( profile, accessToken, refreshToken, agent, next) ->
  create( profile, accessToken, refreshToken, agent)
    .then( ( agent ) ->
      next( null, agent)
    )
    .fail( ( err ) ->
      next( err)
    )

verify = ( accessToken, refreshToken, profile, next ) ->

  profile = profile or {}

  if not profile
    next( new UnauthorizedError() )
    return

  promise = null

  if profile.email
    promise = AgentModel
      .search( "email:#{profile.email}", yes)
  else if profile.id
    promise = AgentModel
      .search( "github_id:#{profile.id}", yes)
  else
    next( new UnauthorizedError() )
    return

  promise
    .then( ( agent ) ->
      putAgent( profile, accessToken, refreshToken, agent, next )
    )
    .fail( ( err ) ->
      if err not instanceof NotFoundError
        next( err )
        return
      putAgent( profile, accessToken, refreshToken, null, next )
    )

module.exports =
  authenticate: null
  Strategy: null
  setup: (passport) ->
    passport.use(this.Strategy = new GithubStrategy(
      {
        clientID: githubEnv.clientId,
        clientSecret: githubEnv.clientSecret,
        callbackURL: githubEnv.callbackUrl,
        scope: githubEnv.scope
      },
      verify ))
    this.authenticate = passport.authenticate(
      'github',
      {
        session: false,
        failureRedirect: '/agent/authenticate/failed'
      }
    )