var CircleModel, Model, schema;

Model = require('../../riak/Model');

schema = require('./schema');

CircleModel = Model.define({
  type: 'persona',
  bucket: 'persona',
  schema: schema
});

module.exports = CircleModel;

/*
//# sourceMappingURL=model.js.map
*/
