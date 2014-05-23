"use strict"

###*
Simple module to load deployment configuration from a YAML file.
@module joukou-api/config
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2014 Joukou Ltd. All rights reserved.
###

fs   = require( 'fs' )
path = require( 'path' )
yaml = require( 'js-yaml' )
log  = require( './log/LoggerFactory' ).getLogger( name: 'server' )

try
  module.exports = yaml.safeLoad(
    fs.readFileSync( process.env.JOUKOU_CONFIG, encoding: 'utf8' )
  )
catch e
  log.warn( 'unable to load ' + process.env.JOUKOU_CONFIG )
  module.exports = {}