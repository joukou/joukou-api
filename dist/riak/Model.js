"use strict";

/**
@class joukou-api/riak/Model
@extends events.EventEmitter
@requires lodash
@requires q
@requires node-uuid
@requires joukou-api/riak/Client
@requires joukou-api/riak/MetaValue
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var EventEmitter, self,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

module.exports = self = (function(_super) {
  var MetaValue, Q, riak, uuid, _;

  __extends(_Class, _super);

  self = _Class;

  _ = require('lodash');

  Q = require('q');

  uuid = require('node-uuid');

  riak = require('./Client');

  MetaValue = require('./MetaValue');


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
    this.bucket = _arg.bucket, this.schema = _arg.schema;
    return;
  }


  /**
  @return {string} The bucket name.
   */

  _Class.prototype.getBucket = function() {
    return this.bucket;
  };


  /**
  @return {schemajs} The schema.
   */

  _Class.prototype.getSchema = function() {
    return this.schema;
  };


  /**
  Load a *Value* for `this` *Model* from Basho Riak.
  @param {string} key
  @return {q.promise}
   */

  _Class.prototype.load = function(key) {
    var deferred;
    deferred = Q.defer();
    riak.get({
      bucket: this.bucket,
      key: key
    }).then((function(_this) {
      return function(metaValue) {
        metaValue.setModel(_this);
        return deferred.resolve(metaValue);
      };
    })(this)).fail(function(err) {
      return deferred.reject(err);
    });
    return deferred.promise;
  };


  /**
  Create a new *Value* for `this` *Model* in Basho Riak.
  @param {Object.<string,(string|number)>} rawValue The raw data from the client.
  @return {q.promise}
   */

  _Class.prototype.create = function(rawValue) {
    var deferred, errors, metaValue, valid, value, _ref;
    deferred = Q.defer();
    _ref = this.getSchema().validate(rawValue), value = _ref.value, errors = _ref.errors, valid = _ref.valid;
    if (!valid) {
      process.nextTick(function() {
        return deferred.reject(errors);
      });
      return deferred.promise;
    }
    metaValue = new MetaValue({
      bucket: this.bucket,
      key: uuid.v4(),
      value: value
    });
    riak.put({
      metaValue: metaValue
    }).then(function() {
      return deferred.resolve(value, meta);
    }).fail(function(err) {
      return deferred.reject(err);
    });
    return deferred.promise;
  };

  return _Class;

})(EventEmitter);

/*
//# sourceMappingURL=Model.js.map
*/
