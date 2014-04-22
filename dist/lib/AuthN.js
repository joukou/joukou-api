"use strict";

/**
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
 */
module.exports = new ((function() {
  var BasicStrategy, BcryptError, RiakError, bcrypt, passport, riak, util, _;

  _ = require('lodash');

  bcrypt = require('bcrypt');

  BcryptError = require('./error/BcryptError');

  passport = require('passport');

  BasicStrategy = require('passport-http').BasicStrategy;

  util = require('util');

  riak = require('./riak/Client');

  RiakError = require('./error/RiakError');


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
    return riak.query('agents', {
      email: username
    }, function(err, keys, meta) {
      var key;
      if (err) {
        return next(new RiakError(err));
      }
      if (_.isEmpty(keys)) {
        return next(null, false);
      }
      key = _.first(keys);
      return riak.get('agents', key, function(err, agent, meta) {
        if (err) {
          if (err.notFound) {
            return next(null, false);
          } else {
            return next(new RiakError(err));
          }
        } else {
          return bcrypt.compare(password, agent.password, function(err, authenticated) {
            if (err) {
              return next(new BcryptError(err));
            }
            if (authenticated) {
              return next(null, _.extend(_.omit(agent, 'password'), {
                key: key
              }));
            }
            return next(null, false);
          });
        }
      });
    });
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
