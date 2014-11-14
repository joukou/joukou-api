
authn        = require( '../authn' )
GitHubApi    = require( 'github' )
env          = require( '../env' )
_            = require( 'lodash' )
Q            = require( 'q' )
PersonaModel = require( '../persona/model' )
AgentModel   = require( '../agent/model' )

module.exports = self =
  registerRoutes: ( server ) ->
    server.get(
      '/agent/github/repos',
      authn.authenticate,
      self.getRepositoriesForAgent
    )
    server.get(
      '/persona/github/repos',
      authn.authenticate,
      self.getRepositoriesForPersona
    )

  siftRepositories: (repositories, additionalProperties = {}) ->
    repositories = _.where(repositories, (repository) ->
      return repository and
          repository["permissions"] and
          repository["permissions"]["pull"]
    )

    return _.map(repositories, (repository) ->
      representation =
        id: repository.id
        name: repository.name
        full_name: repository.full_name
        private: repository.private
        fork: repository.fork
        url: repository.url
        html_url: repository.html_url
        git_url: repository.git_url
        ssh_url: repository.ssh_url
        clone_url: repository.clone_url
        homepage: repository.homepage or repository.html_url
        created_at: repository.created_at
        updated_at: repository.updated_at
        pushed_at: repository.pushed_at
        owner_login: repository.owner.login
        owner_id: repository.owner.id
        owner_url: repository.owner.url
        owner_html_url: repository.owner.html_url
        owner_avatar_url: repository.owner.avatar_url

      return representation
    )

  $getRepositoriesForAgentOrganizations: (github) ->
    deferred = Q.defer()
    github.user.getOrgs({}, (err, organizations) ->
      if err
        deferred.resolve([])
        return
      promises = _.map(organizations, (organization) ->
        oDeferred = Q.defer()
        github.orgs.getTeams(org: organization.login, (err, teams) ->
          if err
            oDeferred.resolve([])
            return
          promises = _.map(teams, (team) ->
            tDeferred = Q.defer()
            github.orgs.getTeamRepos({
              id: team.id
              per_page: "100"
            }, (err, repositories) ->
              if err
                tDeferred.resolve([])
                return
              tDeferred.resolve(
                self.siftRepositories(repositories)
              )
            )
            tDeferred.promise
          )
          Q.all(
            promises
          )
          .then((repositories) ->
            return _.flatten(repositories)
          )
          .then(oDeferred.resolve)
          .fail(oDeferred.reject)
        )
        return oDeferred.promise
      )
      Q.all(
        promises
      )
      .then((repositories) ->
        return _.flatten(repositories)
      )
      .then(deferred.resolve)
      .fail(deferred.reject)
    )
    return deferred.promise

  $getRepositoriesForAgentPersonal: (github) ->
    deferred = Q.defer()
    github.repos.getAll({
      sort: 'updated',
      per_page: "100"
    },(err, repositories) ->
      if err
        deferred.resolve([])
        return
      deferred.resolve(
        self.siftRepositories(repositories)
      )
    )
    return deferred.promise

  $getRepositoriesForAgent: (agent) ->
    deferred = Q.defer()
    value = agent.getValue()
    token = value.github_token

    if not token
      deferred.reject({
        code: 401
        message: "No authorization token for GitHub"
      })
      return

    github = new GitHubApi(
      version: "3.0.0"
      protocol: "https"
      host: "api.github.com"
      timeout: 100000
      debug: no
    )
    github.authenticate(
      type: "oauth"
      token: token
    )
    Q.all([
      self.$getRepositoriesForAgentOrganizations(github)
      self.$getRepositoriesForAgentPersonal(github)
    ])
    .then((repositories) ->
      return _.flatten(repositories)
    )
    .then(deferred.resolve)
    .fail(deferred.reject)

    return deferred.promise

  $getRepositoriesForPersona: (persona) ->
    value = persona.getValue()
    agents = value.agents or []
    promises = _.map(agents, (agent) ->
      deferred = Q.defer()
      AgentModel.retrieve(agent.key)
      .then((agent) ->
        deferred.resolve(self.$getRepositoriesForAgent(agent))
      )
      .fail(deferred.reject)
      return deferred.promise
    )
    Q.all(promises)
    .then((repositories) ->
      return _.flatten(repositories)
    )

  getRepositoriesForPersona: (req, res, next) ->
    PersonaModel.getForAgent(req.user.getKey())
    .then((personas) ->
      promises = _.map(
        personas,
        self.$getRepositoriesForPersona
      )
      Q.all(
        promises
      )
      .then((repositories) ->
        res.send(200, _.flatten(repositories))
      )
    )
    .fail((error) ->
      next(error)
    )

  getRepositoriesForAgent: (req, res, next) ->
    self.$getRepositoriesForAgent(req.user)
      .then((repositories) ->
        res.send(200, repositories)
      )
      .fail((error) ->
        if error and error.code
          res.send(error.code, error.message)
          return
        next(error)
      )

