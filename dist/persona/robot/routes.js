var PersonaModel, authn, restify, robot, self, uuid;

robot = require('../../authn/creators/robot');

authn = require('../../authn');

PersonaModel = require('../model');

restify = require('restify');

uuid = require('node-uuid');

module.exports = self = {
  registerRoutes: function(server) {
    server.post('/persona/:personaKey/robot', authn.authenticate, self.create);
  },
  create: function(req, res, next) {
    return PersonaModel.retrieve(req.params.personaKey).then(function(persona) {
      return robot.create(persona).then(function(robot) {
        var value;
        value = robot.getValue();
        value.jwt_token = uuid.v4();
        robot.setValue(value);
        return robot.save().then(function() {
          var represntation;
          represntation = {
            name: value.name,
            key: robot.getKey(),
            access_token: authn.Bearer.generate(robot, value.jwt_token)
          };
          if (req.accepts("application/hal+json")) {
            represntation["_embedded"] = {
              'joukou:agent': {
                name: value.name,
                _links: {
                  self: "/agent/" + (robot.getKey())
                }
              }
            };
          }
          return res.send(200, represntation);
        });
      }).fail(function(err) {
        return res.send(503, err);
      });
    }).fail(function() {
      return next(new restify.UnauthorizedError());
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
