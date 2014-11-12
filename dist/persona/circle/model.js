var CircleModel, Model, Q, schema;

Model = require('../../riak/Model');

schema = require('./schema');

Q = require('q');

CircleModel = Model.define({
  type: 'circle',
  bucket: 'circle',
  schema: schema
});

CircleModel.afterCreate = function(circle) {
  circle.afterRetrieve();
  return Q.resolve(circle);
};

CircleModel.retrieveByPersona = function(key) {
  return CircleModel.search("personas.key:" + key, 'personas.key');
};

CircleModel.prototype.beforeSave = function() {};

CircleModel.prototype.afterRetrieve = function() {
  this.addSecondaryIndex('name_bin');
  return this.addSecondaryIndex('personas.key_bin');
};

module.exports = CircleModel;

/*
//# sourceMappingURL=model.js.map
*/
