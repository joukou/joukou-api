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
var GraphModel, PersonaModel, Q, UnauthorizedError, self, _;

_ = require('lodash');

Q = require('q');

PersonaModel = require('../persona/model');

GraphModel = require('../persona/graph/model');

UnauthorizedError = require('restify').UnauthorizedError;

self = {
  hasPermission: function(agent, permission) {
    throw new Error("Not implemented");
  },
  getRoles: function(agent) {
    var value;
    value = agent.getValue();
    return value.roles || [];
  },
  hasRole: function(agent, role) {
    return self.getRoles(agent).indexOf(role) !== -1;
  },
  hasSomeRoles: function(agent, roles) {
    var agentRoles;
    agentRoles = self.getRoles(agent);
    return _.some(roles, function(role) {
      return agentRoles.indexOf(role) !== -1;
    });
  },
  hasPersona: function(agent, personaKey) {
    var deferred;
    if (!agent || !agent.getKey instanceof Function || typeof personaKey !== 'string') {
      process.nextTick(function() {
        return deferred.reject(new UnauthorizedError('Agent or persona key not valid'));
      });
      return deferred.promise;
    }
    deferred = Q.defer();
    PersonaModel.retrieve(personaKey).then(function(persona) {
      var has, key, value;
      value = persona.getValue();
      key = agent.getKey();
      has = _.some(value.agents, function(agent) {
        return agent.key === key;
      });
      if (has) {
        return deferred.resolve(persona);
      } else {
        return deferred.reject(new UnauthorizedError('Persona does not have agent'));
      }
    }).fail(function() {
      return deferred.reject(new UnauthorizedError('Failed to retrieve persona'));
    });
    return deferred.promise;
  },
  hasCircle: function(agent, circleKey) {
    var deferred;
    deferred = Q.defer();
    PersonaModel.getForAgent(agent.getKey()).then(function(personas) {
      return CircleModel.retrieve(circleKey).then(function(circle) {
        var has, keys;
        keys = _.map(personas, function(persona) {
          return persona.getKey();
        });
        has = _.some(circle.personas, function(persona) {
          return keys.indexOf(persona.key) !== -1;
        });
        if (has) {
          return deferred.resolve(circle);
        } else {
          return deferred.reject(new UnauthorizedError('Cannot access circle'));
        }
      });
    }).fail(function() {
      return deferred.reject(new UnauthorizedError('Failed to retrieve personas'));
    });
    return deferred.promise;
  },
  hasGraph: function(agent, graphKey, personaKey) {
    var deferred;
    deferred = Q.defer();
    if (typeof graphKey !== 'string') {
      process.nextTick(function() {
        return deferred.reject(new UnauthorizedError('Graph key is not a string'));
      });
      return deferred.promise;
    }
    self.hasPersona(agent, personaKey).then(function(persona) {
      return GraphModel.retrieve(graphKey).then(function(graph) {
        var has, key, value;
        value = graph.getValue();
        key = persona.getKey();
        has = _.some(value.personas, function(persona) {
          return persona.key === key;
        });
        if (has) {
          return deferred.resolve({
            persona: persona,
            graph: graph
          });
        } else {
          return deferred.reject(new UnauthorizedError('Graph does not have persona'));
        }
      }).fail(function() {
        return deferred.reject(new UnauthorizedError('Failed to retrieve graph'));
      });
    }).fail(function() {
      return deferred.reject(new UnauthorizedError('Cannot access persona'));
    });
    return deferred.promise;
  }
};

module.exports = self;

/*
//# sourceMappingURL=index.js.map
*/
