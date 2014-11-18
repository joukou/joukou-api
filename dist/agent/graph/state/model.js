var GraphStateModel, Model, Q, schema;

schema = require('./schema');

Model = require('../../../riak/Model');

Q = require('q');

GraphStateModel = Model.define({
  schema: schema,
  type: 'graph_state',
  bucket: 'graph_state'
});

GraphStateModel.retrieveForGraph = function(agentKey, graphKey) {
  return GraphStateModel.search("agent_key:" + agentKey + " graph_key:" + graphKey, {
    firstOnly: true
  });
};

GraphStateModel.put = function(agentKey, graphKey, state) {
  var data, deferred, numberOr, save;
  if (state == null) {
    state = {};
  }
  deferred = Q.defer();
  save = function(model) {
    return model.save().then(function() {
      return deferred.resolve(model);
    }).fail(deferred.reject);
  };
  numberOr = function(number, other) {
    if (typeof number !== 'number') {
      return other;
    }
    if (isNaN(number)) {
      return other;
    }
    return number;
  };
  data = {
    agent_key: agentKey,
    graph_key: graphKey,
    x: numberOr(state.x),
    y: numberOr(state.y),
    scale: numberOr(state.scale),
    metadata: state.metadata || {}
  };
  GraphStateModel.retrieveForGraph(agentKey, graphKey).then(function(model) {
    model.setValue(data);
    return save(model);
  }).fail(function() {
    return GraphStateModel.create(data).then(save).fail(deferred.reject);
  });
  return deferred.promise;
};

GraphStateModel.afterCreate = function(model) {
  model.afterRetrieve();
  return Q.resolve(model);
};

GraphStateModel.prototype.beforeSave = function() {};

GraphStateModel.prototype.afterRetrieve = function() {
  this.addSecondaryIndex('agent_key_bin');
  return this.addSecondaryIndex('graph_key_bin');
};

module.exports = GraphStateModel;

/*
//# sourceMappingURL=model.js.map
*/
