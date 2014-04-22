"use strict";

/**
@class joukou-api.model.Agent
@requires joukou-api.schema.Agent
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
 */
var self;

module.exports = self = (function() {

  /**
  @static
  @property {joukou-api.schema.Agent} schema
   */
  _Class.schema = require('../schema/Agent');

  function _Class(rawData) {
    this.rawData = rawData;
    this.data = self.schema.validate(this.rawData);
  }


  /**
  @method isValid
  @returns {Boolean}
   */

  _Class.prototype.isValid = function() {
    return this.data.valid;
  };

  return _Class;

})();

/*
//# sourceMappingURL=Agent.js.map
*/
