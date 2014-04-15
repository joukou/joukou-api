"use strict"
###*
@class joukou-api.server
@requires source-map-support
@requires restify
@requires joukou-api.log.LoggerFactory
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
###

require( 'source-map-support' ).install()

restify       = require( 'restify' )
LoggerFactory = require( './lib/log/LoggerFactory' )
AuthN         = require( './lib/AuthN' )
routes        = require( './lib/routes' )

module.exports = server = restify.createServer(
  name: 'joukou.co'
  version: require( '../package.json' ).version
  log: LoggerFactory.getLogger( name: 'server' )
)

server.use( restify.acceptParser( server.acceptable ) )
server.use( restify.dateParser() )
server.use( restify.queryParser() )
server.use( restify.jsonp() )
server.use( restify.gzipResponse() )
server.use( restify.bodyParser( mapParams: false ) )
server.use( AuthN.middleware( ) )

server.on( 'after', restify.auditLogger(
  log: LoggerFactory.getLogger( name: 'audit' )
) )

routes.registerRoutes(server)

server.listen(
  process.env.JOUKOU_PORT or 3000,
  process.env.JOUKOU_HOST or 'localhost',
  ->
    server.log.info(
      '%s-%s listening at %s',
      server.name,
      require('../package.json').version,
      server.url
    )
)
