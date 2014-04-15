"use strict"
###*
@class joukou-api.AuthN
@requires lodash
@requires bcrypt
@requires joukou-api.error.BcryptError
@requires passport
@requires passport-http
@requires util
@requires joukou-api.riak.Client
@requires joukou-api.error.RiakError

Authentication singleton based on Passport.
###

module.exports = new class

  _                 = require( 'lodash' )
  bcrypt            = require( 'bcrypt' )
  BcryptError       = require( './error/BcryptError' )
  passport          = require( 'passport' )
  { BasicStrategy } = require( 'passport-http' )
  util              = require( 'util' )
  riak              = require( './riak/Client' )
  RiakError         = require( './error/RiakError' )

  ###*
  @method constructor
  ###
  constructor: ->
    passport.use( new BasicStrategy( _.bind( @verify, @ ) ) )

  ###*
  @method verify
  @param {String} username The user's email addess
  @param {String} password The user's plaintext password
  @param {Function} next
  ###
  verify: ( username, password, next ) ->
    credentials =
      username: 'username'
      password: 'password'

    if username is credentials.username and password is credentials.password
      return next( null, { username: username, password: password } )
    else
      return next( null, false )



    ###
    riak.query( 'agents', email: username, ( err, keys, meta ) ->
      return next( new RiakError(err) ) if err
      return next( null, false ) if _.isEmpty( keys )
      key = _.first( keys )
      riak.get( 'agents', key, ( err, agent, meta ) ->
        if err
          if err.notFound
            return next( null, false )
          else
            return next( new RiakError( err ) )
        else
          bcrypt.compare( password, agent.password, ( err, authenticated ) ->
            return next( new BcryptError( err ) ) if err
            if authenticated
              return next(
                null,
                _.extend( _.omit( agent, 'password' ), key: key )
              )
            next( null, false )
          )
      )
    )
    ###

  ###*
  @method middleware
  ###
  middleware: ->
    passport.initialize()

  ###*
  @method authenticate
  ###
  authenticate: passport.authenticate( 'basic', session: false )
