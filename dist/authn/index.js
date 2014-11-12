var Bearer, Github, passport;

passport = require('passport');

Github = require('./github');

Bearer = require('./bearer');

Github.setup(passport);

Bearer.setup(passport);

module.exports = {
  Github: Github,
  Bearer: Bearer,
  authenticate: Bearer.authenticate,
  middleware: function() {
    return passport.initialize();
  }
};

/*
//# sourceMappingURL=index.js.map
*/
