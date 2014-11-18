var GraphStateModel, authenticate, self;

GraphStateModel = require('./state/model');

authenticate = require('../../authn').authenticate;

module.exports = self = {

  /**
  Register the `/agent/graph` routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.put('/agent/graph/:graphKey/state', authenticate, self.updateState);
    return server.get('/agent/graph/:graphKey/state', authenticate, self.retrieveState);
  },
  retrieveState: function(req, res, next) {
    return GraphStateModel.retrieveForGraph(req.user.getKey(), req.params.graphKey).then(function(state) {
      state = model.getValue();
      return res.send(200, {
        scale: state.scale,
        x: state.x,
        y: state.y
      });
    }).fail(function() {
      return res.send(200, {
        scale: 1,
        x: 0,
        y: 0
      });
    });
  },
  updateState: function(req, res, next) {
    return GraphStateModel.put(req.user.getKey(), req.params.graphKey, req.body).then(function(model) {
      return res.send(200, model.getValue());
    }).fail(next);
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
