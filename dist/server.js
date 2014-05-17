"use strict";

/**
@module joukou-api/server
@requires source-map-support
@requires restify
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2013 Joukou Ltd. All rights reserved.
 */
var LoggerFactory, authn, restify, routes, server;

require('source-map-support').install();

restify = require('restify');

authn = require('./authn');

routes = require('./routes');

LoggerFactory = require('./log/LoggerFactory');

module.exports = server = restify.createServer({
  name: 'joukou.com',
  version: require('../package.json').version,
  log: LoggerFactory.getLogger({
    name: 'server'
  })
});

server.use(restify.acceptParser(server.acceptable));

server.use(restify.dateParser());

server.use(restify.queryParser());

server.use(restify.jsonp());

server.use(restify.gzipResponse());

server.use(restify.bodyParser({
  mapParams: false
}));

server.use(authn.middleware());

server.on('after', restify.auditLogger({
  log: LoggerFactory.getLogger({
    name: 'audit'
  })
}));

routes.registerRoutes(server);

server.listen(process.env.JOUKOU_PORT || 3000, process.env.JOUKOU_HOST || 'localhost', function() {
  return server.log.info('%s-%s listening at %s', server.name, require('../package.json').version, server.url);
});

/*
//# sourceMappingURL=server.js.map
*/
