var AgentModel, GitHubApi, PersonaModel, Q, authn, env, self, _;

authn = require('../authn');

GitHubApi = require('github');

env = require('../env');

_ = require('lodash');

Q = require('q');

PersonaModel = require('../persona/model');

AgentModel = require('../agent/model');

module.exports = self = {
  registerRoutes: function(server) {
    server.get('/agent/github/repos', authn.authenticate, self.getRepositoriesForAgent);
    return server.get('/persona/github/repos', authn.authenticate, self.getRepositoriesForPersona);
  },
  siftRepositories: function(repositories, additionalProperties) {
    if (additionalProperties == null) {
      additionalProperties = {};
    }
    repositories = _.where(repositories, function(repository) {
      return repository && repository["permissions"] && repository["permissions"]["pull"];
    });
    return _.map(repositories, function(repository) {
      var representation;
      representation = {
        id: repository.id,
        name: repository.name,
        full_name: repository.full_name,
        "private": repository["private"],
        fork: repository.fork,
        url: repository.url,
        html_url: repository.html_url,
        git_url: repository.git_url,
        ssh_url: repository.ssh_url,
        clone_url: repository.clone_url,
        homepage: repository.homepage || repository.html_url,
        created_at: repository.created_at,
        updated_at: repository.updated_at,
        pushed_at: repository.pushed_at,
        owner_login: repository.owner.login,
        owner_id: repository.owner.id,
        owner_url: repository.owner.url,
        owner_html_url: repository.owner.html_url,
        owner_avatar_url: repository.owner.avatar_url
      };
      return representation;
    });
  },
  $getRepositoriesForAgentOrganizations: function(github) {
    var deferred;
    deferred = Q.defer();
    github.user.getOrgs({}, function(err, organizations) {
      var promises;
      if (err) {
        deferred.resolve([]);
        return;
      }
      promises = _.map(organizations, function(organization) {
        var oDeferred;
        oDeferred = Q.defer();
        github.orgs.getTeams({
          org: organization.login
        }, function(err, teams) {
          if (err) {
            oDeferred.resolve([]);
            return;
          }
          promises = _.map(teams, function(team) {
            var tDeferred;
            tDeferred = Q.defer();
            github.orgs.getTeamRepos({
              id: team.id,
              per_page: "100"
            }, function(err, repositories) {
              if (err) {
                tDeferred.resolve([]);
                return;
              }
              return tDeferred.resolve(self.siftRepositories(repositories));
            });
            return tDeferred.promise;
          });
          return Q.all(promises).then(function(repositories) {
            return _.flatten(repositories);
          }).then(oDeferred.resolve).fail(oDeferred.reject);
        });
        return oDeferred.promise;
      });
      return Q.all(promises).then(function(repositories) {
        return _.flatten(repositories);
      }).then(deferred.resolve).fail(deferred.reject);
    });
    return deferred.promise;
  },
  $getRepositoriesForAgentPersonal: function(github) {
    var deferred;
    deferred = Q.defer();
    github.repos.getAll({
      sort: 'updated',
      per_page: "100"
    }, function(err, repositories) {
      if (err) {
        deferred.resolve([]);
        return;
      }
      return deferred.resolve(self.siftRepositories(repositories));
    });
    return deferred.promise;
  },
  $getRepositoriesForAgent: function(agent) {
    var deferred, github, token, value;
    deferred = Q.defer();
    value = agent.getValue();
    token = value.github_token;
    if (!token) {
      deferred.reject({
        code: 401,
        message: "No authorization token for GitHub"
      });
      return;
    }
    github = new GitHubApi({
      version: "3.0.0",
      protocol: "https",
      host: "api.github.com",
      timeout: 100000,
      debug: false
    });
    github.authenticate({
      type: "oauth",
      token: token
    });
    Q.all([self.$getRepositoriesForAgentOrganizations(github), self.$getRepositoriesForAgentPersonal(github)]).then(function(repositories) {
      return _.flatten(repositories);
    }).then(deferred.resolve).fail(deferred.reject);
    return deferred.promise;
  },
  $getRepositoriesForPersona: function(persona) {
    var agents, promises, value;
    value = persona.getValue();
    agents = value.agents || [];
    promises = _.map(agents, function(agent) {
      var deferred;
      deferred = Q.defer();
      AgentModel.retrieve(agent.key).then(function(agent) {
        return deferred.resolve(self.$getRepositoriesForAgent(agent));
      }).fail(deferred.reject);
      return deferred.promise;
    });
    return Q.all(promises).then(function(repositories) {
      return _.flatten(repositories);
    });
  },
  getRepositoriesForPersona: function(req, res, next) {
    return PersonaModel.getForAgent(req.user.getKey()).then(function(personas) {
      var promises;
      promises = _.map(personas, self.$getRepositoriesForPersona);
      return Q.all(promises).then(function(repositories) {
        return res.send(200, _.flatten(repositories));
      });
    }).fail(function(error) {
      return next(error);
    });
  },
  getRepositoriesForAgent: function(req, res, next) {
    return self.$getRepositoriesForAgent(req.user).then(function(repositories) {
      return res.send(200, repositories);
    }).fail(function(error) {
      if (error && error.code) {
        res.send(error.code, error.message);
        return;
      }
      return next(error);
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
