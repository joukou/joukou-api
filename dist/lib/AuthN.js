"use strict";

/**
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
 */
module.exports = new ((function() {

  /**
  @private
  @static
  @property {lodash} _
   */
  var BasicStrategy, passport, riakpbc, _;

  _ = require('lodash');


  /**
  @private
  @static
  @property {passport} passport
   */

  passport = require('passport');


  /**
  @private
  @static
  @property {passport-http.BasicStrategy} BasicStrategy
   */

  BasicStrategy = require('passport-http').BasicStrategy;


  /**
  @private
  @static
  @property {joukou-api.riakpbc.client} riakpbc
   */

  riakpbc = require('./riakpbc/client');


  /**
  @method constructor
   */

  function _Class() {
    passport.use(new BasicStrategy(_.bind(this.verify, this)));
  }


  /**
  @method verify
  @param {String} username The user's email addess
  @param {String} password The user's plaintext password
  @param {Function} next
   */

  _Class.prototype.verify = function(username, password, next) {
    var user;
    user = UserModel.load(username);
    return user.verifyPassword(password).then(function(authenticated) {
      if (authenticated) {
        return next(null, user);
      } else {
        return next(null, false);
      }
    }).fail(function(err) {
      return next(err);
    });

    /*
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
     */
  };


  /**
  @method middleware
   */

  _Class.prototype.middleware = function() {
    return passport.initialize();
  };


  /**
  @method authenticate
   */

  _Class.prototype.authenticate = passport.authenticate('basic', {
    session: false
  });

  return _Class;

})());

/*
//# sourceMappingURL=AuthN.js.map
*/
