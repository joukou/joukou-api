

module.exports = self =

  getEnvironment: ->
    switch process.env.NODE_ENV
      when 'production'
        'production'
      when 'staging'
        'staging'
      else
        'development'

  getHost: ->
    switch self.getEnvironment()
      when 'production'
        'https://api.joukou.com'
      when 'staging'
        'https://staging-api.joukou.com'
      else
        'http://127.0.0.1:2101'

  getFQDN: ->
    switch self.getEnvironment()
      when 'production'
        'api.joukou.com'
      when 'staging'
        'staging-api.joukou.com'
      else
        'localhost'

  getServerName: ->
    switch self.getEnvironment()
      when 'production', 'staging'
        self.getFQDN()
      else
        require( '../package.json' ).name

  getVersion: ->
    require( '../package.json' ).version

  getOrigins: ->
    switch self.getEnvironment()
      when 'production'
        [
          'https://joukou.com'
        ]
      when 'staging'
        [
          'https://staging.joukou.com'
          'http://localhost:2100'
          'http://127.0.0.1:2100'
        ]
      else
        [
          'http://localhost:2100'
          'http://127.0.0.1:2100'
        ]

  getOrigin: ->
    return self.getOrigins()[0]

  getJWTKey: ->
    return 'abc'

  getGithubAuth: ->
    origin = self.getOrigin()
    host = self.getHost()
    clientId = null
    clientSecret = null

    if self.getEnvironment() is 'development'
      origin += '/build/testing'

    switch self.getEnvironment()
      when 'production'
        clientId = "REPLACEME"
        clientSecret = "REPLACEME"
      when 'staging'
        clientId = "REPLACEME"
        clientSecret = "REPLACEME"
      else
        clientId = "3b349282176a33f7f42e"
        clientSecret = "6befeffabcecf885ebeb8e9b95695c5a4c021461"

    {
      clientId: clientId
      clientSecret: clientSecret
      callbackUrl: host + "/agent/authenticate/callback"
      failedUrl: origin + "/index.html#/auth/callback/failed"
      successUrl: origin + "/index.html#/auth/callback/success"
      scope: [
        # Associate user with email
        'user:email'
        # See public and private repositories
        'repo'
        # Get deployment statuses
        'repo_deployment'
        # Grants read and ping access to hooks
        'read:repo_hook'
        # Associate user with other users
        'read:org'
      ]
    }
