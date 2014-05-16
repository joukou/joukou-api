"use strict";

/**
@class joukou-api/riakpbc/Value
 */
var EventEmitter,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

module.exports = (function(_super) {
  var self;

  __extends(_Class, _super);

  self = _Class;


  /**
  @constructor
   */

  function _Class(_arg) {
    this.key = _arg.key, this.model = _arg.model, this.rawData = _arg.rawData, this.riakData = _arg.riakData;
    this.phantom = !!this.rawData;
  }

  _Class.prototype.validate = function() {
    var _ref;
    if (this.rawData) {
      _ref = this.model.getSchema().validate(this.rawData), this.valid = _ref.valid, this.data = _ref.data, this.errors = _ref.errors;
    } else {
      this.valid = true;
      this.data = this.riakData;
    }
    return this.valid;
  };

  _Class.prototype.isValid = function() {
    return this.valid;
  };

  _Class.prototype.getErrors = function() {
    return this.errors;
  };


  /**
  Check if an object already exists in Basho Riak with the same `bucket` and
  `key` as this model instance.
  @return {q.promise}
   */

  _Class.prototype.exists = function() {
    var deferred;
    deferred = Q.defer();
    riakpbc.get({
      bucket: this.bucket,
      key: this.key
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


  /**
  Persist this model instance in Basho Riak. Uses {@link #exists|exists} to
  check if an object already exists in Basho Riak with the same `bucket` and
  `key` as this model instance, and rejects the promise if it does.
  @return {q.promise}
   */

  _Class.prototype.save = function() {
    var deferred;
    deferred = Q.defer();
    this.exists().then((function(_this) {
      return function(exists) {
        if (exists) {
          return deferred.reject(new DuplicateError(_this.key));
        } else {
          return riakpbc.put({
            bucket: _this.bucket,
            key: _this.data[_this.key],
            content: _this.data
          }, function(err, reply) {
            if (err) {
              return deferred.reject(new RiakError(err));
            } else {
              return deferred.resolve();
            }
          });
        }
      };
    })(this));
    return deferred.promise;
  };

  return _Class;

})(EventEmitter);

/*
//# sourceMappingURL=Value.js.map
*/
