"use strict"

###*
{@link module:joukou-api/persona/graph/process/Model|Process} APIs provide the
ability to inspect and create *Processes* for a *Graph*.

@module joukou-api/persona/graph/process/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

authn      = require( '../../../authn' )
hal        = require( '../../../hal' )
GraphModel = require( '../model' )
{ UnauthorizedError, ForbiddenError, NotFoundError } = require( 'restify' )
Q          = require( 'q' )
_          = require( 'lodash' )

self =

  ###*
  Registers process-related routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(
      '/persona/:personaKey/graph/:graphKey/process',
      authn.authenticate, self.index
    )
    server.post(
      '/persona/:personaKey/graph/:graphKey/process',
      authn.authenticate, self.create
    )
    server.put(
      '/persona/:personaKey/graph/:graphKey/process/:processKey',
      authn.authenticate, self.update
    )
    server.put(
      '/persona/:personaKey/graph/:graphKey/process/:processKey/position',
      authn.authenticate, self.updatePosition
    )
    server.get(
      '/persona/:personaKey/graph/:graphKey/process/:processKey',
      authn.authenticate, self.retrieve
    )
    server.del(
      '/persona/:personaKey/graph/:graphKey/process/:processKey',
      authn.authenticate, self.remove
    )
    server.post(
      '/persona/:personaKey/graph/:graphKey/process/clone',
      authn.authenticate, self.clone
    )
    return

  ###
  @api {get} /persona/:personaKey/graph/:graphKey/process List of Processes for a Graph
  @apiName ProcessIndex
  @apiGroup Graph
  @apiParam {String} personaKey Personas unique key.
  @apiParam {String} graphKey Graphs unique key.
  ###

  ###*
  Handles a request for a list of *Processes* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  index: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        graph.getProcesses( ( processes ) ->
          personaHref = "/persona/#{persona.getKey()}"
          res.link( personaHref, 'joukou:persona' )
          graphHref = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}"
          res.link( graphHref, 'joukou:graph' )
          res.link( "#{graphHref}/process", 'joukou:process-create' )

          representation = {}
          representation._embedded = _.reduce( processes, ( process, key ) ->
            metadata: process.metadata
            _links:
              self:
                href: "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{key}"
              'joukou:circle':
                href: "/persona/#{persona.getKey()}/circle/#{process.circle.key}"
              'joukou:persona':
                href: personaHref
              'joukou:graph':
                href: graphHref
          , { 'joukou:process': [] } )

          res.send( 200, representation )
        )
      )
    )
    .fail( ( err ) -> next( err ) )

  ###
  @api {post} /persona/:personaKey/graph/:graphKey/process
  @apiName CreateProcess
  @apiGroup Graph
  ###

  ###*
  Handles a request to create a *Process* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  create: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        data = {}
        data.metadata = req.body.metadata

        document = hal.parse( req.body,
          links:
            'joukou:circle':
              min: 1
              max: 1
              match: '/persona/:personaKey/circle/:key'
        )

        unless document.links[ 'joukou:circle' ]?[ 0 ].personaKey is persona.getKey()
          throw new ForbiddenError( 'attempt to use a circle from a different persona' )

        data.circle =
          key: document.links[ 'joukou:circle' ]?[ 0 ].key
        #console.log(require('util').inspect(data, depth: 10))

        graph.addProcess( data ).then( ( processKey ) ->
          graph.save().then( ->
            self = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{processKey}"
            res.link( self, 'joukou:process' )
            res.link( "#{self}/position", 'joukou:process-update:position' )
            res.header( 'Location', self )
            res.send( 201, {} )
          )
        )
      )
    )
    .fail( ( err ) -> next( err ) )
    return

  ###
  @api {get} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName RetrieveProcess
  @apiGroup Graph
  ###

  ###*
  Handles a request to retrieve a *Process*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  retrieve: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        graph.getProcesses().then( ( processes ) ->
          process = processes[ req.params.processKey ]
          unless process
            throw new NotFoundError()
          representation = {}
          representation.metadata = process.metadata
          res.link( "/persona/#{persona.getKey()}/circle/#{process.circle.key}", 'joukou:circle' )
          res.send( 200, representation )
        )
      )
    )
    .fail( ( err ) -> next( err ) )
    return

  ###
  @api {put} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName UpdateProcess
  @apiGroup Graph
  ###

  ###*
  Handles a request to update a *Process* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  update: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        data = {}
        data.metadata = req.body.metadata

        document = hal.parse( req.body,
          links:
            'joukou:circle':
              min: 1
              max: 1
              match: '/persona/:personaKey/circle/:key'
        )

        unless document.links[ 'joukou:circle' ]?[ 0 ].personaKey is persona.getKey()
          throw new ForbiddenError( 'attempt to use a circle from a different persona' )

        data.circle =
          key: document.links[ 'joukou:circle' ]?[ 0 ].key
        #console.log(require('util').inspect(data, depth: 10))

        value = graph.getValue()
        value.processes[req.params.processKey] = data
        graph.setValue(value)

        graph.save().then( ->
          self = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{req.params.processKey}"
          res.link( self, 'joukou:process' )
          res.link( "#{self}/position", 'joukou:process-update:position' )
          res.header( 'Location', self )
          res.send( 200, {} )
        )
      )
    )
    .fail( ( err ) -> next( err ) )


  ###
  @api {put} /persona/:personaKey/graph/:graphKey/process/:processKey/position
  @apiName UpdateProcessPosition
  @apiGroup Graph
  ###

  ###*
  Handles a request to update a *Process* position for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  updatePosition: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->

        value = graph.getValue()
        process = value.processes[req.params.processKey]
        process.metadata.x = req.body.x
        process.metadata.y = req.body.y
        graph.setValue(value)

        graph.save().then( ->
          self = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{req.params.processKey}"
          res.link( self, 'joukou:process' )
          res.link( "#{self}/position", 'joukou:process-update:position' )
          res.header( 'Location', self )
          res.send( 200, {} )
        )
      )
    )
    .fail( ( err ) -> next( err ) )

  ###
  @api {delete} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName DeleteProcess
  @apiGroup Graph
  ###

  ###*
  Handles a request to delete a *Process* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  remove: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->

        value = graph.getValue()
        value.processes[req.params.processKey] = undefined
        graph.setValue(value)

        graph.save().then( ->
          res.send( 204, {} )
        )
      )
    )
    .fail( ( err ) -> next( err ) )

  ###
  @api {post} /persona/:personaKey/graph/:graphKey/process/clone
  @apiName CloneProcess
  @apiGroup Graph
  ###

  ###*
  Handles a request to clone *Processes* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  clone: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->

        edges = req.body.edges or []
        nodes = req.body.nodes or []

        if nodes.length is 0
          return res.send(400)

        shouldReturn = no

        _.each(edges, (edge) ->
          if (
            not edge or
            not edge.from or
            not edge.from.node or
            not edge.from.port or
            not edge.to or
            not edge.to.node or
            not edge.to.port
          )
            res.send(400, "edge doesn't have the required values")
            shouldReturn = yes
            return false
        )

        if shouldReturn
          return

        _.each(nodes, (node) ->
          if (
            not node or
            not node.component or
            not node.id or
            not node.metadata or
            not node.metadata.key or
            not node.metadata.circle or
            not node.metadata.circle.key or
            not node.metadata.circle.value
          )
            res.send(400, "node doesn't have the required values")
            shouldReturn = yes
            return false
        )

        if shouldReturn
          return

        processes = {}
        connections = []

        processMap = {}

        promises = _.map(nodes, (node) ->
          deferred = Q.defer()
          circle = {
            key: node.metadata.circle.key
          }
          metadata = {
            x: node.metadata.x
            y: node.metadata.y
          }
          graph.addProcess({circle: circle, metadata: metadata})
          .then((key) ->
            processMap[node.id] = key
            processes[key] = {
              id: processId(key)
              component: circle.key
              metadata:
                nodeId: node.id
                x: metadata.x
                y: metadata.y
                circle:
                  circle.key
                key: key
            }
            deferred.resolve(key)
          )
          .fail(deferred.reject)
          return deferred.promise
        )

        processId = (key) ->
          return "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{key}"

        processPort = (port) ->
          port.process = processId(port.process)
          return port

        addConnections = ->
          connectionPromises = _.map(edges, (edge) ->
            data = {}
            data.metadata = {}
            data.src = {
              process: processMap[edge.from.node] || edge.from.node
              port: edge.from.port
              metadata: {}
            }
            data.tgt = {
              process: processMap[edge.to.node] || edge.to.node
              port: edge.to.port
              metadata: {}
            }
            deferred = Q.defer()
            graph.addConnection(data)
            .then((connection) ->
              data = _.cloneDeep(data)
              data.metadata.key = connection.key
              data.src = processPort(data.src)
              data.tgt = processPort(data.tgt)
              connections.push(data)
              deferred.resolve(connection)
            )
            .fail(deferred.reject)
            return deferred.promise
          )

          Q.all(
            connectionPromises
          )
          .then( ->
            graph.save().then( ->
              res.send(200, {
                processes: processes
                connections: connections
              })
            )
          )

        Q.all(
          promises
        )
        .then(addConnections)
        .fail((error) ->
          res.send(400, error)
        )
      )
    )
    .fail( ( err ) -> next( err ) )

module.exports = self

