"use strict";

/**
@class joukou-api/riakpbc/Model
@extends events.EventEmitter
@requires lodash
@requires q
@requires node-uuid
@requires joukou-api/riakpbc/client
@requires joukou-api/error/RiakError
@requires restify/NotFoundError
@requires joukou-api/riakpbc/Value
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var EventEmitter, self,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

module.exports = self = (function(_super) {
  var NotFoundError, Q, RiakError, Value, riakpbc, uuid, _;

  __extends(_Class, _super);

  self = _Class;

  _ = require('lodash');

  Q = require('q');

  uuid = require('node-uuid');

  riakpbc = require('./client');

  RiakError = require('../error/RiakError');

  NotFoundError = require('restify').NotFoundError;

  Value = require('./Value');


  /**
  Create a model definition.
  @function factory
  @static
   */

  _Class.factory = function(options) {
    return new self(options);
  };


  /**
  @constructor
   */

  function _Class(_arg) {
    this.schema = _arg.schema, this.bucket = _arg.bucket;
    return;
  }


  /**
  Load a *Value* for `this` *Model* from Basho Riak.
  @param {string} key
  @return {q.promise}
   */

  _Class.prototype.load = function(key) {
    var deferred;
    deferred = Q.defer();
    riakpbc.get({
      bucket: this.bucket,
      key: key
    }, function(err, reply) {
      if (err) {
        deferred.reject(new RiakError(err));
      } else {
        if (_.isEmpty(reply)) {
          deferred.reject(new NotFoundError());
        } else {
          deferred.resolve(new Value({
            model: this,
            key: key,
            riakData: reply.content
          }));
        }
      }
    });
    return deferred.promise;
  };


  /**
  Create a new *Value* for `this` *Model* in Basho Riak.
  @param {Object.<string,(string|number)>} rawData The raw data from the client.
  @return {q.promise}
   */

  _Class.prototype.create = function(rawData) {
    var deferred, value;
    deferred = Q.defer();
    value = new Value({
      model: this,
      key: uuid.v4(),
      rawData: rawData
    });
    if (!value.isValid()) {
      return deferred.reject();
    } else {
      return value.save().then(function() {
        return deferred.resolve(value);
      }).fail(function(err) {
        return deferred.reject(err);
      });
    }
  };

  return _Class;

})(EventEmitter);

/*
//# sourceMappingURL=Model.js.map
*/
