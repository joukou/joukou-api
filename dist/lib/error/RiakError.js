
/**
@class joukou-api.error.RiakError
@extends restify.RestError
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
 */
var self,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = self = (function(_super) {
  __extends(_Class, _super);

  function _Class(originalError) {
    this.originalError = originalError;
    _Class.__super__.constructor.call(this, {
      restCode: 'InternalError',
      statusCode: 503,
      message: '',
      constructorOpt: self
    });
  }

  return _Class;

})(RestError);

/*
//# sourceMappingURL=RiakError.js.map
*/
