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
@module joukou-api/server
@requires source-map-support
@requires restify
@author Isaac Johnston <isaac.johnston@joukou.com>
###

require( 'source-map-support' ).install()

restify       = require( 'restify' )
authn         = require( './authn' )
cors          = require( './cors' )
env           = require( './env' )
hal           = require( './hal' )
routes        = require( './routes' )

LoggerFactory = require( './log/LoggerFactory' )

module.exports = server = restify.createServer(
  name: env.getServerName()
  version: env.getVersion()
  formatters:
    'application/json': hal.formatter
  log: LoggerFactory.getLogger( name: 'server' )
  acceptable: [
    'application/json'
    'application/hal+json'
  ]
)

server.pre( cors.preflight )
server.use( cors.actual )
server.use( restify.acceptParser( server.acceptable ) )
server.use( restify.dateParser() )
server.use( restify.queryParser() )
server.use( restify.jsonp() )
server.use( restify.gzipResponse() )
server.use( restify.bodyParser( mapParams: false ) )
server.use( authn.middleware( ) )
server.use( hal.link( ) )

server.on( 'after', restify.auditLogger(
  log: LoggerFactory.getLogger( name: 'audit' )
) )

routes.registerRoutes( server )

server.listen(
  # Port 2101 is for develop/staging, 2201 is for production!
  process.env.JOUKOU_API_PORT or 2101,
  process.env.JOUKOU_API_HOST or 'localhost',
  ->
    server.log.info(
      '%s-%s listening at %s',
      server.name,
      env.getVersion(),
      server.url
    )
)
