"use strict";

/*
Authorization.

@module joukou-api/authz
@requires lodash
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */

/*
@apiDefinePermission guest Unauthenticated users have access.
Anyone with access to the public internet may access these resources.
 */

/*
@apiDefinePermission agent Agent access rights required.
An *Agent* is authorized to act on behalf of a *Persona* (called the
*Principal*).
 */

/*
@apiDefinePermission operator Operator access rights required.
An *Operator* is a person that is involved in providing the services of this
Joukou platform installation.
 */
var self, _;

_ = require('lodash');

module.exports = self = {

  /**
  Check if the given `agent` has the given `permission`.
   */
  hasPermission: function(agent, permission) {}
};

/*
//# sourceMappingURL=authz.js.map
*/
