"use strict"
###*
@class joukou-api.AuthN
@requires lodash
@requires bcrypt
@requires passport
@requires passport-http
@requires util
@requires joukou-api.riakpbc.client
@requires joukou-api.error.BcryptError
@requires joukou-api.error.RiakError

Authentication singleton based on Passport.
###

module.exports = new class

  ###*
  @private
  @static
  @property {lodash} _
  ###
  _ = require( 'lodash' )

  ###*
  @private
  @static
  @property {passport} passport
  ###
  passport = require( 'passport' )

  ###*
  @private
  @static
  @property {passport-http.BasicStrategy} BasicStrategy
  ###
  { BasicStrategy } = require( 'passport-http' )

  ###*
  @private
  @static
  @property {joukou-api.riakpbc.client} riakpbc
  ###
  riakpbc = require( './riakpbc/client' )



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
    user = UserModel.load( username )
    user.verifyPassword( password ).then( ( authenticated ) ->
      if authenticated
        next( null, user )
      else
        next( null, false )
    ).fail( ( err ) ->
      next( err )
    )



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
