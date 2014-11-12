var AgentModel, Persona, Q, create, setupPersona;

Q = require('q');

Persona = require('./persona');

AgentModel = require('../../agent/model');

setupPersona = function(agent) {
  return Persona.create("Default Persona", [
    {
      key: agent.getKey(),
      role: 'creator'
    }
  ]);
};

create = function(value) {
  var deferred;
  deferred = Q.defer();
  AgentModel.create(value).then(function(agent) {
    return agent.save().then(function() {
      return setupPersona(agent).then(function() {
        return deferred.resolve(agent);
      });
    });
  }).fail(deferred.reject);
  return deferred.promise;
};

module.exports = {
  create: create
};

/*
//# sourceMappingURL=agent.js.map
*/
