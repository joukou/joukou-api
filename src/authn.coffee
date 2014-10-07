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
AgentModel        = require( './agent/Model' )
{ UnauthorizedError, NotFoundError } = require( 'restify' )
env               = require( './env' )
Q                 = require( 'q' )
BearerStrategy    = require( 'passport-http-bearer' ).Strategy
jwt               = require( 'jsonwebtoken' )

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
        next( null, agent.getValue() )
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

verifyToken = (token, next) ->
  obj = jwt.decode(token)
  notAuth = ->
    next(new UnauthorizedError())
  if not obj or obj not instanceof Object
    notAuth()
    return
  email = null
  if typeof obj["email"] is "string"
    email = obj["email"]
  else if obj["value"] instanceof Object and typeof obj["value"]["email"] is "string"
    email = obj["value"]["email"]
  else
    notAuth()
    return
  AgentModel
    .retrieveByEmail(obj["email"])
      .then( (agent) ->
        next(null, agent)
      )
      .fail( (err) ->
        if err instanceof NotFoundError
          notAuth()
          return
        next(err)
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
  else if typeof agent["email"] is "string"
    value = agent
  if not value
    return ""
  jwt.sign(agent, env.getJWTKey())


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

