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
        like = CircleModel.likeQuery("name", req.params.name);
        return CircleModel.search("personas.key:" + (persona.getKey()) + " AND\n" + like);
      });
      return Q.all(promises).then(function(circles) {
        var representation;
        representation = {};
        representation.result = _.map(_.flatten(circles, true), function(circle) {
          var value;
          value = circle.getValue();
          return {
            key: circle.getKey(),
            name: value.name,
            description: value.description,
            icon: value.icon,
            subgraph: value.subgraph,
            image: value.image
          };
        });
        if (req.accepts("application/hal+json")) {
          representation["_embedded"] = {
            "joukou:circle": _.map(representation.result, function(circle) {
              circle = _.cloneDeep(circle);
              circle._links = {
                self: {
                  href: "/circle/" + circle.key
                }
              };
              return circle;
            })
          };
        }
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
