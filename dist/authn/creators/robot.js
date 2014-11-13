var AgentModel, Q, create, roboname, uuid;

roboname = require('roboname');

Q = require('q');

uuid = require('node-uuid');

AgentModel = require('../../agent/model');

create = function(persona) {
  var deferred;
  deferred = Q.defer();
  AgentModel.create({
    email: "" + (uuid.v4()) + "@robot.joukou.com",
    website: "robot.joukou.com",
    name: roboname(),
    company: "Robots @ Joukou",
    location: "The cloud"
  }).then(function(agent) {
    return agent.save().then(function(agent) {
      var value;
      value = persona.getValue();
      value.agents = value.agents || [];
      value.agents.push({
        key: agent.getKey(),
        role: 'robot'
      });
      persona.setValue(value);
      return persona.save().then(function() {
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
//# sourceMappingURL=robot.js.map
*/
