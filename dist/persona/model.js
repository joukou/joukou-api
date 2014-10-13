"use strict";

/**
persona is from greek prosōpon meaning "mask" or "character". Personas are a
legal person (Latin: persona ficta) or a natural person
(Latin: persona naturalis).

@class joukou-api/persona/Model
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
@author Isaac Johnston <isaac.johnston@joukou.com>
 */
var Model, PersonaModel, Q, schema, _;

_ = require('lodash');

Q = require('q');

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

module.exports = PersonaModel;

/*
//# sourceMappingURL=model.js.map
*/
