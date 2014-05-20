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
var EventEmitter, MetaValue, Q, riak, uuid, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

_ = require('lodash');

Q = require('q');

uuid = require('node-uuid');

riak = require('./Client');

MetaValue = require('./MetaValue');

module.exports = {
  define: function(_arg) {
    var bucket, schema, type;
    type = _arg.type, bucket = _arg.bucket, schema = _arg.schema;
    if (type == null) {
      type = 'default';
    }
    return (function(_super) {
      var self;

      __extends(_Class, _super);

      self = _Class;

      _Class.getType = function() {
        return type;
      };

      _Class.getBucket = function() {
        return bucket;
      };

      _Class.getSchema = function() {
        return schema;
      };


      /**
      Create a new *Value* for `this` *Model* in Basho Riak.
      @param {Object.<string,(string|number)>} rawValue The raw data from the client.
      @return {q.promise}
       */

      _Class.create = function(rawValue) {
        var beforeCreate, deferred, errors, valid, value, _ref;
        deferred = Q.defer();
        _ref = self.getSchema().validate(rawValue), value = _ref.value, errors = _ref.errors, valid = _ref.valid;
        if (!valid) {
          process.nextTick(function() {
            return deferred.reject(errors);
          });
          return deferred.promise;
        }
        if (self.beforeCreate) {
          beforeCreate = self.beforeCreate(value);
        } else {
          beforeCreate = Q.fcall(function() {
            return value;
          });
        }
        beforeCreate.then(function(value) {
          var metaValue;
          metaValue = new MetaValue({
            type: this.getType(),
            bucket: this.bucket,
            key: uuid.v4(),
            value: value
          });
          return riak.put({
            metaValue: metaValue
          }).then(function() {
            return deferred.resolve(metaValue);
          }).fail(function(err) {
            return deferred.reject(err);
          });
        });
        return deferred.promise;
      };


      /**
      Retrieve a *Model* instance of this *Model* class from Basho Riak.
      @param {string} key
      @return {q.promise}
       */

      _Class.retrieve = function(key) {
        var deferred;
        deferred = Q.defer();
        riak.get({
          type: self.getType(),
          bucket: self.getBucket(),
          key: key
        }).then(function(metaValue) {
          return deferred.resolve(new self({
            metaValue: metaValue
          }));
        }).fail(function(err) {
          return deferred.reject(err);
        });
        return deferred.promise;
      };


      /**
      @constructor
       */

      function _Class(_arg1) {
        this.metaValue = _arg1.metaValue;
      }


      /**
      Get the *MetaValue* instance for `this` *Modal* instance.
      @return {joukou-api/riak/MetaValue}
       */

      _Class.prototype.getMetaValue = function() {
        return this.metaValue;
      };


      /**
      Get value of the *MetaValue* instance for `this` *Modal* instance.
      @return {!Object}
       */

      _Class.prototype.getValue = function() {
        return this.getMetaValue().getValue();
      };

      return _Class;

    })(EventEmitter);
  }
};

/*
//# sourceMappingURL=Model.js.map
*/
