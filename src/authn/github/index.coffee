Q              = require( 'q' )
env            = require( '../../env' )
{ UnauthorizedError, NotFoundError } = require( 'restify' )
githubEnv      = env.getGithubAuth()
AgentModel     = require( '../../agent/model' )
_              = require( 'lodash' )
Agent          = require( '../creators/agent' )
GithubStrategy = require( 'passport-github' ).Strategy


create = ( profile, agent ) ->
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

putAgent = ( profile, agent, next) ->
  create( profile, agent)
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
      putAgent( profile, agent, next )
    )
    .fail( ( err ) ->
      if err not instanceof NotFoundError
        next( err )
        return
      putAgent( profile, null, next )
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