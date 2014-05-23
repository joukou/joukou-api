
/**
@class joukou-api/riak/NotFoundError
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = (function(_super) {
  __extends(_Class, _super);


  /**
  @constructor
   */

  function _Class(message) {
    _Class.__super__.constructor.call(this, message);
    this.notFound = true;
    return;
  }

  return _Class;

})(Error);

/*
//# sourceMappingURL=NotFoundError.js.map
*/
