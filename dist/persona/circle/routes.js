"use strict";

/**
{@link module:joukou-api/persona/circle/Model|Circle} APIs provide information
about the available Circles. In future the ability to create, sell and buy
Circles will be added.

@module joukou-api/persona/circle/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var CircleModel, CircleRoutes, self, _;

CircleModel = require('../../circle/model');

_ = require('lodash');

CircleRoutes = require('../../circle/routes');

module.exports = self = {
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/circle', self.index);
    server.get('/persona/:personaKey/circle', self.retrieve);
  },
  retrieve: function(req, res, next) {
    return CircleRoutes.retrieve(req, res, next);
  },
  index: function(req, res, next) {
    return CircleModel.retrieveByPersona(req.params.personaKey).then(function(circles) {
      var representation;
      representation = {};
      if (req.accepts('application/hal+json')) {
        representation["_embedded"] = {
          "joukou:circle": _.map(circles, function(circle) {
            var value;
            value = circle.getValue();
            value.key = circle.getKey();
            value._links = {
              self: {
                href: "/persona/" + req.params.personaKey + "/circle/" + (circle.getKey())
              },
              'joukou:persona': {
                href: "/persona/" + req.params.personaKey
              }
            };
            return value;
          })
        };
      } else {
        representation.circles = _.map(circles, function(circle) {
          return circle.getValue();
        });
      }
      return res.send(200, representation);
    }).fail(next);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
