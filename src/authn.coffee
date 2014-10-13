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

# Don't know why but I can't get two passport types to work
# oh well, go with it for now TODO fix it
passport          = require( 'passport' )
passportBearer    = require( 'passport' )
GithubStrategy    = require( 'passport-github' ).Strategy
AgentModel        = require( './agent/model' )
{ UnauthorizedError, NotFoundError } = require( 'restify' )
env               = require( './env' )
Q                 = require( 'q' )
BearerStrategy    = require( 'passport-http-bearer' ).Strategy
jwt               = require( 'jsonwebtoken' )
_                 = require( 'lodash' )
PersonaModel      = require( './persona/model' )
GraphModel        = require( './persona/graph/model' )



githubProfileToAgent = ( profile, agent ) ->
  deferred = Q.defer()
  profile = profile._json || profile

  if not profile
    deferred.reject(new Error("Profile not provided"))
    return
  if not profile.email or not profile.id or not profile.name
    deferred.reject(new Error("Required details not provided"))
    return

  creating = no

  afterCreation = ( actualAgent ) ->
    # Setup default persona and default graph
    afterDeferred = Q.defer()
    createdPersona = ( persona ) ->
      data = {}
      data.name = "Default graph"
      data.personas = [
        key: persona.getKey()
      ]
      GraphModel.create(data)
        .then( (graph) ->
          graph.save()
        )
        .then( ->
          afterDeferred.resolve()
        )
        .fail(afterDeferred.reject)
    PersonaModel.create(
      name: "Default persona"
      agents: [
        {
          key: actualAgent.getKey()
          role: 'creator'
        }
      ])
        .then( (persona) ->
          persona.save()
            .then( ->
              createdPersona(persona)
            )
            .fail(afterDeferred.reject)
        )
        .fail(afterDeferred.reject)
    return afterDeferred.promise

  created = ( actualAgent ) ->
    value = actualAgent.getValue() or {}
    _.assign(value,
      email: profile.email
      github_login: profile.login
      github_id: profile.id
      image_url: profile.avatar_url
      website: profile.blog
      github_url: profile.url
      name: profile.name
      company: profile.company
      location: profile.location)
    actualAgent.setValue(value)
    actualAgent.save()
      .then( ( agent ) ->
        if not creating
          deferred.resolve(actualAgent)
          return
        afterCreation(actualAgent)
          .then( ->
            deferred.resolve(actualAgent)
          )
          .fail(deferred.reject)
      )
      .fail( (err) ->
        deferred.reject(err)
      )
    undefined

  if agent
    created(agent)
  else
    creating = yes
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

  promise = null

  profile = profile or {}
  profile = profile._json or profile

  if not profile
    next( new UnauthorizedError() )
    return

  if profile.email
    promise = AgentModel
      .retrieveByEmail( profile.email )
  else
    promise = AgentModel
      .retriveByGithubId( profile.id )

  promise
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

verifyToken = (token, next) ->
  notAuth = ->
    next(new UnauthorizedError())

  jwt.verify(token, env.getJWTKey(), (err, obj) ->
    if err
      notAuth()
      return
    obj = jwt.decode(token)
    if not obj or obj not instanceof Object
      notAuth()
      return
    if not obj["email"]
      notAuth()
      return
    AgentModel
    .retrieveByEmail(obj["email"])
    .then( (agent) ->
      next(null, agent)
    )
    .fail( (err) ->
      if err instanceof NotFoundError
        console.log(obj["email"])
        notAuth()
        return
      next(err)
    )
  )

githubEnv = env.getGithubAuth()

passport.use( new GithubStrategy(
  {
    clientID: githubEnv.clientId,
    clientSecret: githubEnv.clientSecret,
    callbackURL: githubEnv.callbackUrl
  },
  verify ))

passportBearer.use( new BearerStrategy(verifyToken))

authenticate = passport.authenticate( 'github', session: false, failureRedirect: '/agent/authenticate/failed')

authenticateToken = passportBearer.authenticate('bearer', session: false )

generateTokenFromAgent = (agent) ->
  if not agent or agent not instanceof Object
    return ""
  value = null
  if agent["getValue"] instanceof Function
    # It is an instanceof model
    value = agent["getValue"]()
  else
    value = agent
  if not value
    return ""
  jwt.sign(value, env.getJWTKey())


module.exports = self =
  ###*
  @func middleware
  ###
  middleware: ->
    passport.initialize()

  ###*
  @func authenticate
  ###
  # We want authenticate to authenticate with token
  # To do a sign on use authenticateOAuth
  authenticate: authenticateToken
  authenticateOAuth: authenticate
  authenticateToken: authenticateToken
  generateTokenFromAgent: generateTokenFromAgent

