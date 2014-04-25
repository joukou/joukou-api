"use strict";

/**
@class joukou-api.routes.index
@author Juan Morales <juan@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var users;

users = require('./Users');

module.exports = {
  registerRoutes: function(server) {
    return users.registerRoutes(server);
  }
};

/*
//# sourceMappingURL=index.js.map
*/
