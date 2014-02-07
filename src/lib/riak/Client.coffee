"use strict"
###*
@class joukou-server.riak.Client
@requires riak-js

Pre-configured riak-js client.
###

riak = require( 'riak-js' )

module.exports = riak.getClient(
  host: 'localhost'
  port: 8098
  debug: true
)