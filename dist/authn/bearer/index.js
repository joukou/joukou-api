var BearerStrategy, token;

BearerStrategy = require('passport-http-bearer').Strategy;

token = require('../token');

module.exports = {
  authenticate: null,
  generate: token.generate,
  Strategy: null,
  setup: function(passport) {
    passport.use(this.Strategy = new BearerStrategy(token.verify));
    return this.authenticate = passport.authenticate('bearer', {
      session: false
    });
  }
};

/*
//# sourceMappingURL=index.js.map
*/
