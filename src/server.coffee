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
HalFormatter  = require( './lib/hal/Formatter' )
HalLink       = require( './lib/hal/Link' )

server  = restify.createServer(
  name: 'joukou.co'
  version: require( '../package.json' ).version
  formatters:
    'application/hal+json': HalFormatter
  log: LoggerFactory.getLogger( name: 'server' )
)

server.use( restify.acceptParser( server.acceptable ) )
server.use( restify.dateParser() )
server.use( restify.queryParser() )
server.use( restify.jsonp() )
server.use( restify.gzipResponse() )
server.use( restify.bodyParser( mapParams: false ) )
server.use( HalLink )

server.on( 'after', restify.auditLogger(
  log: LoggerFactory.getLogger( name: 'audit' )
) )

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
