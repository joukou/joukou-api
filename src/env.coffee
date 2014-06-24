

module.exports = self =

  getEnvironment: ->
    switch process.env.NODE_ENV
      when 'production'
        'production'
      when 'staging'
        'staging'
      else
        'development'

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
