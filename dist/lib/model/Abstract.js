"use strict";

/**
@class joukou-api.model.Abstract
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.

An abstract base class for models that are persisted to Basho Riak.
 */
var EventEmitter,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

module.exports = (function(_super) {

  /**
  @private
  @static
  @property {joukou-api.model.Abstract} self
   */
  var NotFoundError, Q, RiakError, riakpbc, self;

  __extends(_Class, _super);

  self = _Class;


  /**
  @private
  @static
  @property {q} Q
   */

  Q = require('q');


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

  NotFoundError = require('restify').NotFoundError;


  /**
  @protected
  @static
  @method load
  @param {String} bucket
  @param {String} key
  @param {joukou-api.model.Abstract} model
  @return {q.promise}
   */

  _Class.load = function(bucket, key, model) {
    var deferred;
    deferred = Q.defer();
    riakpbc.get({
      bucket: bucket,
      key: key
    }, function(err, reply) {
      if (err) {
        if (err.notFound) {
          return deferred.reject(new NotFoundError(err));
        } else {
          return deferred.reject(new RiakError(err));
        }
      } else {
        return new model(reply.content);
      }
    });
    return deferred.promise;
  };


  /**
  @method constructor
  @cfg options
  @cfg {schemajs.Schema} options.schema
  @cfg {Object} options.rawData The raw data
  @cfg {Object} options.bucket The Basho Riak bucket name that instances of this
                               model are persisted to.
   */

  function _Class(options) {
    this.setSchema(options.schema);
    this.setRawData(options.rawData);
    this.bucket = options.bucket;
  }


  /**
  @method setRawData
  @param {Object} rawData
   */

  _Class.prototype.setRawData = function(rawData) {
    var _ref;
    this.rawData = rawData;
    _ref = this.schema.validate(this.rawData), this.valid = _ref.valid, this.data = _ref.data, this.errors = _ref.errors;
    this.emit('rawData', this.rawData, this);
    this.emit('data', this.data, this);
    if (!this.valid) {
      this.emit('errors', this.errors, this);
    }
    return this;
  };


  /**
  @method getData
  @return {Object} Filtered version of the raw data.
   */

  _Class.prototype.getData = function() {
    return this.data;
  };


  /**
  @method setSchema
  @param {schemajs.Schema} options.schema
   */

  _Class.prototype.setSchema = function(schema) {
    this.schema = schema;
    this.emit('schema', this.schema, this);
    return this;
  };


  /**
  @method isValid
  @returns {Boolean} `true` if raw data matched the schema, otherwise `false`.
   */

  _Class.prototype.isValid = function() {
    return this.valid;
  };


  /**
  @method getErrors
  @return {Object} Errors found if raw data did not match the schema.
   */

  _Class.prototype.getErrors = function() {
    return this.errors;
  };


  /**
  @method exists
  @param {String} key
  @return {q.promise}
   */

  _Class.prototype.exists = function(key) {
    var deferred;
    deferred = Q.defer();
    riakpbc.get({
      bucket: this.bucket,
      key: key
    }, function(err, reply) {
      if (err) {
        if (err.notFound) {
          return deferred.resolve(true);
        } else {
          return deferred.reject(new RiakError(err));
        }
      } else {
        return deferred.resolve(false);
      }
    });
    return deferred.promise;
  };

  return _Class;

})(EventEmitter);

/*
//# sourceMappingURL=Abstract.js.map
*/
