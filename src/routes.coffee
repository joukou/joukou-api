"use strict"

###*
@module joukou-api/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@author Juan Morales <juan@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

agent   = require( './agent/routes' )
contact = require( './contact/routes' )
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
    network.registerRoutes( server )
    persona.registerRoutes( server )
    runtime.registerRoutes( server )

    server.get( '/', self.index )

  ###
  @api {get} / Joukou API entry point.
  @apiName EntryPoint
  @apiGroup Joukou
  ###
  index: ( req, res, next ) ->
    res.link( '/agent', 'joukou:agent-create', title: 'Create an Agent' )
    res.link( '/agent/authenticate', 'joukou:agent-authn', title: 'Authenticate as an Agent')
    res.link( '/contact', 'joukou:contact', title: 'Send a Message to Joukou Ltd' )
    res.send( 200, {} )