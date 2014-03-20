###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

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
        metadata: state.metadata or {}
      })
    )
    .fail(->
      res.send(200, {
        scale: 1
        x: 0
        y: 0
        metadata: {}
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