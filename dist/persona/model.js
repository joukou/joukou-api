"use strict";

/**
persona is from greek prosōpon meaning "mask" or "character". Personas are a
legal person (Latin: persona ficta) or a natural person
(Latin: persona naturalis).

@class joukou-api/persona/Model
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.com>
 */
var Model, PersonaModel, schema;

Model = require('../riak/Model');

schema = require('./schema');

PersonaModel = Model.define({
  type: 'persona',
  bucket: 'persona',
  schema: schema
});

PersonaModel.prototype.getName = function() {
  return this.getValue().name;
};

PersonaModel.prototype.hasEditPermission = function(user) {
  return _.some(this.getValue().agents, function(agent) {
    return agent.key === user.getKey() && (agent.role === 'admin' || agent.role === 'creator');
  });
};

PersonaModel.prototype.hasReadPermission = function(user) {
  return _.some(this.getValue().agents, function(agent) {
    return agent.key === user.getKey();
  });
};

module.exports = PersonaModel;

/*
//# sourceMappingURL=Model.js.map
*/
