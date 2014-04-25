"use strict";

/**
@class joukou-api.riakpbc.client
@requires riakpbc

Pre-configured Riak protocol buffer client.
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
