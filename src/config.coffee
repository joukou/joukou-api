"use strict"

###*
Simple module to load deployment configuration from a YAML file.
@module joukou-api/config
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2014 Joukou Ltd. All rights reserved.
###

require( 'js-yaml' )

try
  module.exports = require( '../config.yml' )
catch e
  # TODO fatal log error + process.exit(1) ?
  module.exports = {}

