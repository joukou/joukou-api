"use strict";

/**
Simple module to load deployment configuration from a YAML file.
@module joukou-api/config
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2014 Joukou Ltd. All rights reserved.
 */
var e, fs, log, path, yaml;

fs = require('fs');

path = require('path');

yaml = require('js-yaml');

log = require('./log/LoggerFactory').getLogger({
  name: 'server'
});

try {
  module.exports = yaml.safeLoad(fs.readFileSync(path.join(__dirname, '..', 'config.yml'), 'utf8'));
} catch (_error) {
  e = _error;
  log.warn('unable to load ' + path.join(__dirname, '..', 'config.yml'));
  module.exports = {};
}

/*
//# sourceMappingURL=config.js.map
*/
