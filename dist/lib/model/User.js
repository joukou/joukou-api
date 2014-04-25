"use strict";

/**
@class joukou-api.model.User
@extends joukou-api.model.Abstract
@requires joukou-api.schema.User
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var Abstract,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Abstract = require('./Abstract');

module.exports = (function(_super) {

  /**
  @private
  @static
  @property {joukou-api.model.User} self
   */
  var BcryptError, DuplicateError, Q, RiakError, bcrypt, riakpbc, schema, self, _;

  __extends(_Class, _super);

  self = _Class;


  /**
  @private
  @static
  @property {lodash} _
   */

  _ = require('lodash');


  /**
  @private
  @static
  @property {q} Q
   */

  Q = require('q');


  /**
  @private
  @static
  @property {bcrypt} bcrypt
   */

  bcrypt = require('bcrypt');


  /**
  @private
  @static
  @property {joukou-api.error.BcryptError} BcryptError
   */

  BcryptError = require('../error/BcryptError');


  /**
  @private
  @static
  @property {joukou-api.riakpbc.client} riakpbc
   */

  riakpbc = require('../riakpbc/client');


  /**
  @private
  @static
  @property {joukou-api.error.RiakError} RiakError
   */

  RiakError = require('../error/RiakError');


  /**
  @private
  @static
  @property {joukou-api.schema.User} schema
   */

  schema = require('../schema/User');

  DuplicateError = require('../error/DuplicateError');

  _Class.create = function(rawData) {
    return new self({
      rawData: rawData
    });
  };

  _Class.load = function(username) {
    return Abstract.load('users', username, self);
  };


  /**
  @method constructor
  @inheritdocs
   */

  function _Class(options) {
    _.assign(options, {
      schema: schema
    });
  }

  _Class.prototype.verifyPassword = function(password) {
    var deferred;
    deferred = Q.defer();
    bcrypt.compare(password, this.data.password, function(err, authenticated) {
      if (err) {
        return deferred.reject(new BcryptError(err));
      } else {
        return deferred.resolve(authenticated);
      }
    });
    return deferred.promise;
  };

  _Class.prototype.save = function() {
    var deferred;
    deferred = Q.defer();
    this.exists(this.data.username).then(function(exists) {
      if (exists) {
        return deferred.reject(new DuplicateError('username'));
      } else {
        return riakpbc.put({
          bucket: this.bucket,
          key: this.data.username,
          content: this.data
        }, function(err, reply) {
          if (err) {
            return deferred.reject(err);
          } else {
            return deferred.resolve();
          }
        });
      }
    });
    return deferred.promise;
  };

  return _Class;

})(Abstract);

/*
//# sourceMappingURL=User.js.map
*/
