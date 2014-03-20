"use strict"

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

###*
@module joukou-api/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@author Juan Morales <juan@joukou.com>
###

agent   = require( './agent/routes' )
contact = require( './contact/routes' )
persona = require( './persona/routes' )
runtime = require( './runtime/routes' )
github  = require( './github/routes' )
circle  = require( './circle/routes' )

module.exports = self =

  ###*
  Registers all routes with the `server`.
  @param {joukou-api/server} server
  ###
  registerRoutes: ( server ) ->
    agent.registerRoutes( server )
    contact.registerRoutes( server )
    persona.registerRoutes( server )
    runtime.registerRoutes( server )
    github.registerRoutes( server )
    circle.registerRoutes( server )

    server.get( '/', self.index )

  ###
  @api {get} / Joukou API entry point.
  @apiName EntryPoint
  @apiGroup Joukou
  ###
  index: ( req, res, next ) ->
    res.link( '/agent', 'joukou:agent-create', title: 'Create an Agent' )
    res.link( '/agent/authenticate', 'joukou:agent-authn', title: 'Authenticate')
    res.link( '/contact', 'joukou:contact', title: 'Send a Message to Joukou' )
    res.send( 200, {} )