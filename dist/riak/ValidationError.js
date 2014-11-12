
/**
@class joukou-api/riak/ValidationError
@extends restify/RestError
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var RestError, self,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

RestError = require('restify').RestError;

module.exports = self = (function(_super) {
  __extends(_Class, _super);

  _Class.prototype.rawValues = {};

  function _Class(errors, rawValues) {
    _Class.__super__.constructor.call(this, {
      restCode: 'ForbiddenError',
      statusCode: 403,
      message: JSON.stringify(errors),
      constructorOpt: self
    });
    this.rawValues = rawValues;
    return;
  }

  return _Class;

})(RestError);

/*
//# sourceMappingURL=ValidationError.js.map
*/
