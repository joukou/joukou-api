"use strict";

/**
@module joukou-api/server
@requires source-map-support
@requires restify
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var LoggerFactory, authn, cors, env, hal, restify, routes, server;

require('source-map-support').install();

restify = require('restify');

authn = require('./authn');

cors = require('./cors');

env = require('./env');

hal = require('./hal');

routes = require('./routes');

LoggerFactory = require('./log/LoggerFactory');

module.exports = server = restify.createServer({
  name: env.getServerName(),
  version: env.getVersion(),
  formatters: {
    'application/json': hal.formatter
  },
  log: LoggerFactory.getLogger({
    name: 'server'
  }),
  acceptable: ['application/json', 'application/hal+json']
});

server.pre(cors.preflight);

server.use(cors.actual);

server.use(restify.acceptParser(server.acceptable));

server.use(restify.dateParser());

server.use(restify.queryParser());

server.use(restify.jsonp());

server.use(restify.gzipResponse());

server.use(restify.bodyParser({
  mapParams: false
}));

server.use(authn.middleware());

server.use(hal.link());

server.on('after', restify.auditLogger({
  log: LoggerFactory.getLogger({
    name: 'audit'
  })
}));

routes.registerRoutes(server);

server.listen(process.env.JOUKOU_PORT || 2101, process.env.JOUKOU_HOST || 'localhost', function() {
  return server.log.info('%s-%s listening at %s', server.name, env.getVersion(), server.url);
});

/*
//# sourceMappingURL=server.js.map
*/
