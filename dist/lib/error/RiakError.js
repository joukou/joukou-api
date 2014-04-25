
/**
@class joukou-api.error.RiakError
@extends restify.RestError
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var RestError,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

RestError = require('restify').RestError;

module.exports = (function(_super) {

  /**
  @private
  @static
  @property {joukou-api.error.DuplicateError} self
   */
  var self;

  __extends(_Class, _super);

  self = _Class;


  /**
  @method constructor
  @param {Error} originalError
   */

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
