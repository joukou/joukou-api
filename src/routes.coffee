"use strict"

###*
@module joukou-api/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
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
    res.link( 'joukou:agent-create', '/agent' )
    res.link( 'joukou:agent-authn', '/agent/authenticate')
    res.link( 'joukou:contact', '/contact' )
    res.send( 200, {} )