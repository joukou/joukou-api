"use strict";

/**
@module joukou-api/server
@requires source-map-support
@requires restify
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2013 Joukou Ltd. All rights reserved.
 */
var LoggerFactory, authn, cors, getServerName, hal, restify, routes, server;

require('source-map-support').install();

restify = require('restify');

authn = require('./authn');

hal = require('./hal');

routes = require('./routes');

LoggerFactory = require('./log/LoggerFactory');

cors = require('restify-cors-middleware')({
  origins: ['http://localhost:2100', 'http://127.0.0.1:2100', 'https://staging.joukou.com', 'https://joukou.com'],
  allowHeaders: ['accept', 'accept-version', 'content-type', 'request-id', 'origin', 'x-api-version', 'x-request-id'],
  exposeHeaders: ['api-version', 'content-length', 'content-md5', 'content-type', 'date', 'request-id', 'response-time']
});

getServerName = function() {
  switch (process.env.NODE_ENV) {
    case 'production':
      return 'api.joukou.com';
    case 'staging':
      return 'staging-api.joukou.com';
    default:
      return require('../package.json').name;
  }
};

module.exports = server = restify.createServer({
  name: getServerName(),
  version: require('../package.json').version,
  formatters: {
    'application/hal+json': hal.formatter
  },
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

server.pre(cors.preflight);

server.use(cors.actual);

server.use(hal.link());

server.on('after', restify.auditLogger({
  log: LoggerFactory.getLogger({
    name: 'audit'
  })
}));

routes.registerRoutes(server);

server.listen(process.env.JOUKOU_PORT || 2101, process.env.JOUKOU_HOST || 'localhost', function() {
  return server.log.info('%s-%s listening at %s', server.name, require('../package.json').version, server.url);
});

/*
//# sourceMappingURL=server.js.map
*/
