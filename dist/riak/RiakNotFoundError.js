var NotFoundError, self,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

NotFoundError = require('restify').NotFoundError;

module.exports = self = (function(_super) {
  __extends(_Class, _super);

  function _Class(originalError, details) {
    this.originalError = originalError;
    _Class.__super__.constructor.call(this, {
      restCode: 'NotFoundError',
      statusCode: 404,
      message: 'Item not found',
      constructorOpt: self
    });
    this.type = details && details.type;
    this.bucket = details && details.bucket;
    this.key = details && details.key;
    return;
  }

  return _Class;

})(NotFoundError);

/*
//# sourceMappingURL=RiakNotFoundError.js.map
*/
