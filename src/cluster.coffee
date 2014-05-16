"use strict"

###*
Launches a cluster of Joukou API processes to take advantage of multi-core
systems and restarting failed worker processes for reliability.
@module joukou-api/cluster
@requires lodash
@requires cluster
@requires os
@requires path
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.com>
@author Ben Brabant <ben.brabant@joukou.com>
###

_         = require( 'lodash' )
cluster   = require( 'cluster' )
{ cpus }  = require( 'os' )
path      = require( 'path' )
log       = require( './lib/log/LoggerFactory' ).getLogger( name: 'cluster' )

if cluster.isMaster # If this is the master process
  # Fork a new worker process per CPU core
  _.times( cpus().length, -> cluster.fork() )

  # Fork a new worker process on worker death
  cluster.on( 'exit', ( worker, code, signal ) ->
    log.warn(
      'joukou-api worker process %s died (%s / %s).' +
      'Restarting...',
      worker.process.pid, code, signal
    )
    cluster.fork()
  )
else # Otherwise if this is the child process
  require( './server' )

