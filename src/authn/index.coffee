passport  = require( 'passport' )

Github    = require( './github' )
Bearer    = require( './bearer' )

Github.setup( passport )
Bearer.setup( passport )

module.exports =
  Github: Github
  Bearer: Bearer
  # Default authentication method
  authenticate: Bearer.authenticate
  middleware: ->
    return passport.initialize()