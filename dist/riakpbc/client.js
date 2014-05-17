"use strict";

/**
Pre-configured Riak protocol buffer client.

@module joukou-api/riakpbc/client
@requires riakpbc
 */
var riakpbc;

riakpbc = require('riakpbc');

module.exports = riakpbc.createClient({
  host: 'localhost',
  port: 8087
});

/*
//# sourceMappingURL=client.js.map
*/
