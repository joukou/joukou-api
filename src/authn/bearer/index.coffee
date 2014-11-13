BearerStrategy  = require( 'passport-http-bearer' ).Strategy
token           = require( '../token' )


module.exports =
  authenticate: null
  generate: token.generate
  Strategy: null
  setup: ( passport ) ->
    passport.use(this.Strategy = new BearerStrategy(token.verify))
    this.authenticate = passport.authenticate(
      'bearer',
      session: false
    )