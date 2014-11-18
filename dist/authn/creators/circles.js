var CircleModel, Q, circles, create, _;

Q = require('q');

circles = require('./default-circles');

CircleModel = require('../../circle/model');

_ = require('lodash');

create = function(persona) {
  var promises;
  promises = _.map(circles, function(circle) {
    circle.personas = [
      {
        key: persona.getKey()
      }
    ];
    return CircleModel.create(circle).then(function(circle) {
      return circle.save();
    });
  });
  return Q.all(promises);
};

module.exports = {
  create: create
};

/*
//# sourceMappingURL=circles.js.map
*/
