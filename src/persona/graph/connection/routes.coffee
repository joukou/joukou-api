"use strict"

###*
{@link module:joukou-api/persona/graph/connection/Model|Connection} APIs provide
the ability to inspect and create *Connections* for a *Graph*.

@module joukou-api/persona/graph/connection/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

authn         = require( '../../../authn' )
hal           = require( '../../../hal' )
GraphModel    = require( '../Model' )
{ UnauthorizedError, ForbiddenError, NotFoundError } = require( 'restify' )

module.exports = self =

  ###*
  Registers connection-related routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(  '/persona/:personaKey/graph/:graphKey/connection', authn.authenticate, self.index )
    server.post( '/persona/:personaKey/graph/:graphKey/connection', authn.authenticate, self.create )
    server.get(  '/persona/:personaKey/graph/:graphKey/connection/:connectionKey', authn.authenticate, self.retrieve )
    return

  index: ( req, res, next ) ->
    res.send( 503 )

  create: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        unless persona.hasEditPermission( req.user )
          throw new UnauthorizedError()

        data = {}
        data.data = req.body.data
        data.metadata = req.body.metadata

        document = hal.parse( req.body,
          links:
            'joukou:process':
              min: 2
              max: 2
              match: '/persona/:personaKey/graph/:graphKey/process/:key'
              name:
                required: true
                type: 'enum'
                values: [ 'src', 'tgt' ]
        )

        for process in document.links[ 'joukou:process' ]
          data[ process.name ] =
            key: process.key # TODO process.port

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