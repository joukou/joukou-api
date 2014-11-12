"use strict";

/**
In flow-based programs, the logic is defined as a *Graph*. Each node of the
*Graph* is a *Process* that is implemented by a *Circle*, and the edges define
the *Connections* between them.

@class joukou-api/persona/graph/Model
@extends joukou-api/riak/Model
@requires joukou-api/persona/graph/schema
@requires restify.ConflictError
@requires lodash
@requires q
@requires node-uuid
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var ConflictError, GraphModel, Model, PersonaModel, Q, schema, uuid, _;

_ = require('lodash');

Q = require('q');

uuid = require('node-uuid');

Model = require('../../riak/Model');

schema = require('./schema');

PersonaModel = require('../model');

ConflictError = require('restify').ConflictError;

GraphModel = Model.define({
  type: 'graph',
  schema: schema,
  bucket: 'graph'
});

GraphModel.prototype.getPersona = function() {
  return PersonaModel.retrieve(this.getValue().personas[0].key);
};

GraphModel.prototype.addProcess = function(_arg) {
  var circle, key, metadata, _base;
  circle = _arg.circle, metadata = _arg.metadata;
  key = uuid.v4();
  ((_base = this.getValue()).processes != null ? _base.processes : _base.processes = {})[key] = {
    circle: circle,
    metadata: metadata
  };
  return Q.fcall(function() {
    return key;
  });
};

GraphModel.prototype.getProcess = function(key) {
  return Q.fcall((function(_this) {
    return function() {
      return _this.getValue().processes[key];
    };
  })(this));
};

GraphModel.prototype.getProcesses = function() {
  return Q.fcall((function(_this) {
    return function() {
      return _this.getValue().processes;
    };
  })(this));
};

GraphModel.prototype.addConnection = function(_arg) {
  var connection, data, deferred, metadata, src, tgt;
  data = _arg.data, src = _arg.src, tgt = _arg.tgt, metadata = _arg.metadata;
  deferred = Q.defer();
  if (this._hasConnection({
    src: src,
    tgt: tgt
  })) {
    process.nextTick((function(_this) {
      return function() {
        return deferred.reject(new ConflictError(("Graph " + (_this.getKey()) + " already ") + "has an identical connection between the source and the target."));
      };
    })(this));
  } else {
    connection = {
      key: uuid.v4(),
      data: data,
      src: src,
      tgt: tgt,
      metadata: metadata
    };
    this.getValue().connections.push(connection);
    process.nextTick(function() {
      return deferred.resolve(connection);
    });
  }
  return deferred;
};

GraphModel.prototype._hasConnection = function(_arg) {
  var src, tgt;
  src = _arg.src, tgt = _arg.tgt;
  return _.some(this.getValue().connections, function(connection) {
    return _.isEqual(connection.src, src) && _.isEqual(connection.tgt, tgt);
  });
};

GraphModel.prototype.hasConnection = function(options) {
  return Q.fcall((function(_this) {
    return function() {
      return _this._hasConnection(options);
    };
  })(this));
};

GraphModel.prototype.getConnections = function() {
  return Q.fcall((function(_this) {
    return function() {
      return _this.getValue().connections;
    };
  })(this));
};

module.exports = GraphModel;

/*
//# sourceMappingURL=model.js.map
*/