"use strict"

###*
Authentication based on Passport.

@module joukou-api/authn
@requires passport
@requires passport-http
@requires joukou-api/agent/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

passport          = require( 'passport' )
{ BasicStrategy } = require( 'passport-http' )
AgentModel        = require( './agent/Model' )

###*
@private
@func verify
@param {string} username The user's email address
@param {string} password The user's plaintext password
@param {function(Error,*)} next
###
verify = ( username, password, next ) ->
  AgentModel.retrieveByEmail( username ).then( ( agent ) ->
    agent.verifyPassword( password ).then( ( authenticated ) ->
      if authenticated
        next( null, agent )
      else
        next( null, false )
    ).fail( ( err ) ->
      next( err )
    )
  ).fail( ( err ) ->
    next( err )
  )

passport.use( new BasicStrategy( verify ) )

module.exports = self =
  ###*
  @func middleware
  ###
  middleware: ->
    passport.initialize()

  ###*
  @func authenticate
  ###
  authenticate: passport.authenticate( 'basic', session: false )
