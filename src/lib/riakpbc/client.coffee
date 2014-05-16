"use strict"

###*
Pre-configured Riak protocol buffer client.

@module joukou-api/riakpbc/client
@requires riakpbc
###

riakpbc = require( 'riakpbc' )

module.exports = riakpbc.createClient(
  host: 'localhost'
  port: 8087
)