"use strict";

/**
@class joukou-api.cluster
@requires lodash
@requires cluster
@requires os
@requires path
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Brabant <ben.brabant@joukou.co>

Launches a cluster of Joukou API processes to take advantage of multi-core
systems and restarting failed worker processes for reliability.
 */
var cluster, cpus, log, path, _;

_ = require('lodash');

cluster = require('cluster');

cpus = require('os').cpus;

path = require('path');

log = require('./lib/log/LoggerFactory').getLogger({
  name: 'cluster'
});

if (cluster.isMaster) {
  _.times(cpus().length, function() {
    return cluster.fork();
  });
  cluster.on('exit', function(worker, code, signal) {
    log.warn('joukou-api worker process %s died (%s / %s).' + 'Restarting...', worker.process.pid, code, signal);
    return cluster.fork();
  });
} else {
  require('./server');
}

/*
//# sourceMappingURL=cluster.js.map
*/
