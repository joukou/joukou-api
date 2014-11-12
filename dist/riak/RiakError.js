
/**
@class joukou-api/riak/RiakError
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

  function _Class(originalError, model, params) {
    this.originalError = originalError;
    _Class.__super__.constructor.call(this, {
      restCode: 'InternalError',
      statusCode: 503,
      message: 'The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.',
      constructorOpt: self
    });
    this.InnerError = originalError;
    this.model = model;
    this.params = params;
    return;
  }

  return _Class;

})(RestError);

/*
//# sourceMappingURL=RiakError.js.map
*/
