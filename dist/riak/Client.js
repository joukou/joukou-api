"use strict";

/**
Client for Basho Riak 2.0.

Prefers the protocol buffer API, but may fall back to HTTP for missing
functionality.

Search is implemented via solr-client.

@class joukou-api/riak/Client
@requires lodash
@requires q
@requires riakpbc
@requires solr-client
 */
module.exports = new ((function() {
  var MetaValue, NotFoundError, Q, riakpbc, self, _;

  self = _Class;

  _ = require('lodash');

  Q = require('q');

  riakpbc = require('riakpbc');

  MetaValue = require('./MetaValue');

  NotFoundError = require('./NotFoundError');


  /**
  @constructor
   */

  function _Class(options) {
    if (options == null) {
      options = {};
    }
    this.pbc = riakpbc.createClient({
      host: options.pbHost || 'localhost',
      port: options.pbPort || 8087
    });
    return;
  }


  /**
  Fetch a *Value* from the specified bucket type/bucket/key location (specified
  by `type`, `bucket`, and `key` respectively). If the bucket `type` is not
  specified, the `default` bucket type will be used.
  @return {q.promise}
   */

  _Class.prototype.get = function(_arg) {
    var bucket, deferred, key, type;
    type = _arg.type, bucket = _arg.bucket, key = _arg.key;
    deferred = Q.defer();
    if (type == null) {
      type = 'default';
    }
    this.pbc.get({
      bucket: bucket,
      key: key,
      type: type
    }, function(err, reply) {
      var metaValue;
      if (err) {
        return deferred.reject(err);
      } else if (_.isEmpty(reply)) {
        return deferred.reject(new NotFoundError());
      } else {
        metaValue = MetaValue.fromReply({
          type: type,
          bucket: bucket,
          key: key,
          reply: reply
        });
        return deferred.resolve(metaValue);
      }
    });
    return deferred.promise;
  };


  /**
  Stores a `value` under the specified `bucket` and `key`, or under the `bucket`
  and `key` provided by the `metaValue` object.
  @param {string} bucket
  @param {string} key
  @param {joukou-api/riak/Value} value
  @param {joukou-api/riak/Meta} meta
  @return {q.promise}
   */

  _Class.prototype.put = function(_arg) {
    var bucket, deferred, key, metaValue, value;
    bucket = _arg.bucket, key = _arg.key, value = _arg.value, metaValue = _arg.metaValue;
    deferred = Q.defer();
    if (!metaValue && (bucket && key && value)) {
      metaValue = new MetaValue({
        bucket: bucket,
        key: key,
        value: value
      });
    }
    this.pbc.put(metaValue.getParams(), function(err, reply) {
      if (err) {
        return deferred.reject(err);
      } else {
        return deferred.resolve(reply);
      }
    });
    return deferred.promise;
  };

  return _Class;

})());

/*
//# sourceMappingURL=Client.js.map
*/
