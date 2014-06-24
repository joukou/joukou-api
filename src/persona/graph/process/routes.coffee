"use strict"

###*
{@link module:joukou-api/persona/graph/process/Model|Process} APIs provide the
ability to inspect and create connections for a graph.

@module joukou-api/persona/graph/process/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

authn         = require( '../../../authn' )
hal           = require( '../../../hal' )
GraphModel    = require( '../Model' )
{ UnauthorizedError, ForbiddenError, NotFoundError } = require( 'restify' )

module.exports = self =

  ###*
  Registers process-related routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    server.get(  '/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.index )
    server.post( '/persona/:personaKey/graph/:graphKey/process', authn.authenticate, self.create )
    server.get(  '/persona/:personaKey/graph/:graphKey/process/:processKey', authn.authenticate, self.retrieve )
    return

  ###*
  @api {get} /persona/:personaKey/graph/:graphKey/process Process index
  @apiName ProcessIndex
  @apiGroup Graph

  @apiParam {String} personaKey Personas unique key.
  @apiParam {String} graphKey Graphs unique key.
  ###
  index: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        unless persona.hasReadPermission( req.user )
          throw new UnauthorizedError()

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

  ###*
  @api {post} /persona/:personaKey/graph/:graphKey/process
  @apiName AddProcess
  @apiGroup Graph
  ###
  create: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        unless persona.hasEditPermission( req.user )
          throw new UnauthorizedError()
        
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

        graph.addProcess( data ).then( ( processKey ) ->
          graph.save().then( ->
            self = "/persona/#{persona.getKey()}/graph/#{graph.getKey()}/process/#{processKey}"
            res.link( self, 'joukou:process' )
            res.header( 'Location', self )
            res.send( 201, {} )
          )
        )
      )
    )
    .fail( ( err ) -> next( err ) )
    return

  ###*
  @api {get} /persona/:personaKey/graph/:graphKey/process/:processKey
  @apiName RetrieveProcess
  @apiGroup Graph
  ###
  retrieve: ( req, res, next ) ->
    GraphModel.retrieve( req.params.graphKey ).then( ( graph ) ->
      graph.getPersona().then( ( persona ) ->
        unless persona.hasReadPermission( req.user )
          throw new UnauthorizedError()

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