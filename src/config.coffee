"use strict"

###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

###*
Simple module to load deployment configuration from a YAML file.
@module joukou-api/config
@author Isaac Johnston <isaac.johnston@joukou.com>
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