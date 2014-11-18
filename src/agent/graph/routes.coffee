GraphStateModel = require( './state/model' )
authenticate    = require( '../../authn' ).authenticate

module.exports = self =
  ###*
  Register the `/agent/graph` routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.put( '/agent/graph/:graphKey/state', authenticate, self.updateState )
    server.get( '/agent/graph/:graphKey/state', authenticate, self.retrieveState )

  retrieveState: (req, res, next) ->
    GraphStateModel.retrieveForGraph(
      req.user.getKey(),
      req.params.graphKey
    )
    .then((state) ->
      state = model.getValue()
      res.send(200, {
        scale: state.scale
        x: state.x
        y: state.y
      })
    )
    .fail(->
      res.send(200, {
        scale: 1
        x: 0
        y: 0
      })
    )

  updateState: (req, res, next) ->
    GraphStateModel.put(
      req.user.getKey(),
      req.params.graphKey,
      req.body
    )
    .then((model) ->
      res.send(200, model.getValue())
    )
    .fail(next)