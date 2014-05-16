"use strict";

/**
Simple module to load deployment configuration from a YAML file.
@module joukou-api/config
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2014 Joukou Ltd. All rights reserved.
 */
var e;

require('js-yaml');

try {
  module.exports = require('../config.yml');
} catch (_error) {
  e = _error;
  module.exports = {};
}

/*
//# sourceMappingURL=config.js.map
*/
