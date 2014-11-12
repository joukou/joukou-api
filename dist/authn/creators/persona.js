var Circles, Graph, PersonaModel, Q, create, postCreate;

Q = require('q');

PersonaModel = require('../../persona/model');

Circles = require('./circles');

Graph = require('./graph');

postCreate = function(persona) {
  return Q.all([Graph.create(persona), Circles.create(persona)]);
};

create = function(name, agents) {
  var deferred;
  if (name == null) {
    name = "Default Persona";
  }
  if (agents == null) {
    agents = [];
  }
  deferred = Q.defer();
  PersonaModel.create({
    name: name,
    agents: agents
  }).then(function(persona) {
    return persona.save().then(function() {
      return postCreate(persona).then(function() {
        return deferred.resolve(persona);
      });
    });
  }).fail(deferred.reject);
  return deferred.promise;
};

module.exports = {
  create: create
};

/*
//# sourceMappingURL=persona.js.map
*/
