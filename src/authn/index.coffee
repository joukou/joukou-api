passport  = require( 'passport' )

Github    = require( './github' )
Bearer    = require( './bearer' )

Github.setup( passport )
Bearer.setup( passport )

module.exports =
  Github: Github
  Bearer: Bearer
  # Default authentication method
  # Usage:
  #   In the request body or query string
  #     access_token=#{Bearer.generate(agent, false)}
  #   In the headers:
  #     Authorization: Bearer #{Bearer.generate(agent)}
  authenticate: Bearer.authenticate
  middleware: ->
    return passport.initialize()