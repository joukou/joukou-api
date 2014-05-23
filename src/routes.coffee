"use strict"

###*
@module joukou-api/routes
@author Juan Morales <juan@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

agent   = require( './agent/routes' )
contact = require( './contact/routes' )
graph   = require( './graph/routes' )
network = require( './network/routes' )
persona = require( './persona/routes' )
runtime = require( './runtime/routes' )

module.exports = self =

  ###*
  Registers all routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    agent.registerRoutes( server )
    contact.registerRoutes( server )
    graph.registerRoutes( server )
    network.registerRoutes( server )
    persona.registerRoutes( server )
    runtime.registerRoutes( server )

    server.get( '/', self.index )

  index: ( req, res, next ) ->
    res.send( 200 )