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
Launches a cluster of Joukou API processes to take advantage of multi-core
systems and restarting failed worker processes for reliability.
@module joukou-api/cluster
@requires lodash
@requires cluster
@requires os
@requires path
@author Isaac Johnston <isaac.johnston@joukou.com>
@author Ben Brabant <ben.brabant@joukou.com>
###

_         = require( 'lodash' )
cluster   = require( 'cluster' )
{ cpus }  = require( 'os' )
path      = require( 'path' )
log       = require( './log/LoggerFactory' ).getLogger( name: 'cluster' )

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

