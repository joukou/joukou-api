"use strict"

###*
@class joukou-api.riakpbc.client
@requires riakpbc

Pre-configured Riak protocol buffer client.
###

riakpbc = require( 'riakpbc' )

module.exports = riakpbc.createClient(
  host: 'localhost'
  port: 8087
)