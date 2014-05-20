"use strict"

###*
Simple module to load deployment configuration from a YAML file.
@module joukou-api/config
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2014 Joukou Ltd. All rights reserved.
###

yaml = require( 'js-yaml' )

module.exports = yaml.safeLoad( '../config.yml' )
