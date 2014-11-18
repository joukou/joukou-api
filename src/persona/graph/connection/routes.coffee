"use strict"

###*
{@link module:joukou-api/persona/graph/connection/Model|Connection} APIs provide
the ability to inspect and create *Connections* for a *Graph*.

@module joukou-api/persona/graph/connection/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

authn             = require( '../../../authn' )
hal               = require( '../../../hal' )
GraphModel        = require( '../model' )
ConnectionSchema  = require( './schema')
_                 = require( 'lodash' )

{ UnauthorizedError, ForbiddenError, NotFoundError } = require( 'restify' )

module.exports = self =

  ###*
  Registers connection-related routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(
      '/persona/:personaKey/graph/:graphKey/connection',
      authn.authenticate, self.index
    )
    server.post(
      '/persona/:personaKey/graph/:graphKey/connection',
      authn.authenticate, self.create
    )
    server.get(
      '/persona/:personaKey/graph/:graphKey/connection/:connectionKey',
      authn.authenticate, self.retrieve
    )
    server.del(
      '/persona/:personaKey/graph/:graphKey/connection/:connectionKey',
      authn.authenticate, self.remove
    )
    return

  ###
  @api {get} /persona/:personaKey/graph/:graphKey/connection List of Connections for a Graph
  @apiName ConnectionIndex
  @apiGroup Graph
  @apiParam {String} personaKey Persona's unique key
  @apiParam {String} graphKey Graph's unique key
  ###

  ###*
  Handles a request for a list of *Connections* for a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  index: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      # TODO associations and security model should be handled by the model layer
      graph.getPersona().then( ( persona ) ->
        graph.getConnections( ( connections ) ->
          res.send( 200, connections.getRepresentation() )
        )
      )
    ).fail( ( err ) -> next( err ) )
    return

  create: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        data = {}
        data.data = req.body.data
        data.metadata = req.body.metadata

        # TODO HyperSchema vs schemajs+hal
        document = hal.parse( req.body,
          links:
            'joukou:process':
              min: 2
              max: 2
              match: '/persona/:personaKey/graph/:graphKey/process/:key'
              name:
                required: yes
                type: 'enum'
                values: [ 'src', 'tgt' ]
              properties: {
                port:
                  required: yes
                  type: 'string'
                matadata:
                  required: no
                  type: 'object'
              }
        )

        for process in document.links[ 'joukou:process' ]
          data[ process.name ] =
            process: process.key
            port: process.port
            metadata: process.metadata or {}

        graph.addConnection( data ).then( ( connection ) ->
          graph.save().then( ->
            self = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/connection/#{connection.key}"
            res.link( self, 'joukou:connection' )
            res.header( 'Location', self )
            res.send( 201, {} )
          )
        )
      )
    )
    .fail( ( err ) -> next( err ) )

  retrieve: ( req, res, next ) ->
    res.send( 503 )

  ###
  @api {delete} /persona/:personaKey/graph/:graphKey/connection/:connectionKey Remove connection from a grapg
  @apiName ConnectionRemove
  @apiGroup Graph
  @apiParam {String} personaKey Persona's unique key
  @apiParam {String} graphKey Graph's unique key
  @apiParam {String} connectionKey Connection's unique key
  ###

  ###*
  Handles a request for removing a *Connections* from a *Graph*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
  ###
  remove: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      value = graph.getValue()
      connections = value.connections or (value.connections = [])
      _.remove(connections, (connection) ->
        return connection.key is req.params.connectionKey
      )
      graph.setValue(value)
      graph.save()
      .then(->
        res.send(204)
      )
    ).fail( ( err ) -> next( err ) )