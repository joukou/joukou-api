var GraphModel, Q, create;

Q = require('q');

GraphModel = require('../../persona/graph/model');

create = function(persona, name) {
  var deferred;
  if (name == null) {
    name = "Default Graph";
  }
  deferred = Q.defer();
  GraphModel.create({
    name: name,
    personas: [
      {
        key: persona.getKey()
      }
    ]
  }).then(function(graph) {
    return graph.save();
  }).then(deferred.resolve).fail(deferred.reject);
  return deferred.promise;
};

module.exports = {
  create: create
};

/*
//# sourceMappingURL=graph.js.map
*/
