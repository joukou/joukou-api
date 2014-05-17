"use strict"

###*
Authentication based on Passport.

@module joukou-api/authn
@requires lodash
@requires bcrypt
@requires passport
@requires passport-http
@requires util
@requires joukou-api/riakpbc/client
@requires joukou-api/error/BcryptError
@requires joukou-api/error/RiakError
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

_                 = require( 'lodash' )
passport          = require( 'passport' )
{ BasicStrategy } = require( 'passport-http' )
riakpbc           = require( './riakpbc/client' )

###*
@private
@func verify
@param {string} username The user's email address
@param {string} password The user's plaintext password
@param {function(Error,*)} next
###
verify = ( username, password, next ) ->
  agent = agentModel.loadByUsername( username )
  agent.verifyPassword( password ).then( ( authenticated ) ->
    if authenticated
      next( null, agent )
    else
      next( null, false )
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
