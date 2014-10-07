"use strict"

###*
Authentication based on Passport.

@module joukou-api/authn
@requires passport
@requires passport-github
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

passport          = require( 'passport' )
GithubStrategy    = require( 'passport-github' ).Strategy
AgentModel        = require( './agent/Model' )
{ UnauthorizedError, NotFoundError } = require( 'restify' )
env               = require( './env' )
Q                 = require( 'q' )

githubProfileToAgent = ( profile, agent ) ->
  deferred = Q.defer()
  profile = profile._json || profile

  if not profile
    deferred.reject(new Error("Profile not provided"))
    return
  if not profile.email or not profile.id or not profile.name
    deferred.reject(new Error("Required details not provided"))
    return

  created = ( actualAgent ) ->
    actualAgent.setValue(
      email: profile.email
      githubLogin: profile.login
      githubId: profile.id
      imageUrl: profile.avatar_url
      website: profile.blog
      githubUrl: profile.url
      name: profile.name
      company: profile.company
      location: profile.location
    )
    actualAgent.save()
      .then( ( agent ) ->
        deferred.resolve(agent)
      )
      .fail( (err) ->
        deferred.reject(err)
      )
    undefined

  if agent
    created(agent)
  else
    AgentModel.create(
      email: profile.email
    )
      .then(created)
      .fail(deferred.reject)
  deferred.promise

###*
@private
@func verify
@param {string} accessToken
@param {string} refreshToken
@param {object} profile
@param {function(Error,*)} next
###
verify = ( accessToken, refreshToken, profile, next ) ->

  saveOrCreate = (agent) ->
    githubProfileToAgent(profile, agent)
      .then(( agent ) ->
        next( null, agent )
      )
      .fail(( err ) ->
        next( err )
      )

  AgentModel
    .retriveByGithubId( profile.id )
      .then( ( agent ) ->
        # Update Agent
        saveOrCreate(agent)
      )
      .fail( ( err ) ->
        if err not instanceof NotFoundError
          next( err )
          return
        # Create Agent
        saveOrCreate(null)
      )

githubEnv = env.getGithubAuth()

passport.use( new GithubStrategy(
  {
    clientID: githubEnv.clientId,
    clientSecret: githubEnv.clientSecret,
    callbackURL: githubEnv.callbackUrl
  },
  verify ))

module.exports = self =
  ###*
  @func middleware
  ###
  middleware: ->
    passport.initialize()

  ###*
  @func authenticate
  ###
  authenticate: passport.authenticate( 'github',
    session: false
    failureRedirect: '/agent/authenticate/failed'
  )
