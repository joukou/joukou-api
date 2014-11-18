var CircleModel, PersonaModel, Q, authn, self, _;

CircleModel = require('./model');

PersonaModel = require('../persona/model');

_ = require('lodash');

Q = require('q');

authn = require('../authn');

module.exports = self = {
  registerRoutes: function(server) {
    server.get('/circle', authn.authenticate, self.index);
    server.get('/circle/:key', authn.authenticate, self.retrieve);
    server.del('/circle/:key', authn.authenticate, self.remove);
    server.put('/circle/', authn.authenticate, self.create);
    server.get('/circle/search/:name', authn.authenticate, self.search);
  },
  index: function(req, res, next) {},
  retrieve: function(req, res, next) {},
  remove: function(req, res, next) {},
  create: function(req, res, next) {},
  search: function(req, res, next) {
    return PersonaModel.getForAgent(req.user).then(function(personas) {
      var promises;
      promises = _.map(personas, function(persona) {
        var like;
        like = CircleModel.likeQuery("name", req.params.name, "AND");
        return CircleModel.search("personas.key:" + (persona.getKey()) + " AND\n" + like).then(function(result) {
          return {
            persona: persona,
            result: result
          };
        });
      });
      return Q.all(promises).then(function(results) {
        var circles, representation;
        representation = {};
        representation.result = _.map(_.flatten(results, true), function(result) {
          return {
            persona: result.persona,
            result: _.map(result.result, function(circle) {
              var value;
              value = circle.getValue();
              value.key = circle.getKey();
              return value;
            })
          };
        });
        if (req.accepts("application/hal+json")) {
          circles = _.map(representation.result, function(result) {
            var persona;
            persona = result.persona;
            return _.map(result.result, function(circle) {
              circle = _.cloneDeep(circle);
              circle._links = {
                self: {
                  href: "/persona/" + (persona.getKey()) + "/circle/" + circle.key
                },
                'joukou:persona': {
                  href: "/persona/" + (persona.getKey())
                }
              };
              return circle;
            });
          });
          representation["_embedded"] = {
            "joukou:circle": _.flatten(circles, true)
          };
        }
        representation.result = _.map(representation.result, function(result) {
          return result.result;
        });
        representation.result = _.flatten(representation.result, true);
        return res.send(200, representation);
      });
    }).fail(function() {
      return res.send(200, {
        result: []
      });
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
