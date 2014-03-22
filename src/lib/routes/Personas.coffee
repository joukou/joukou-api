"use strict"
###*
@class joukou-server.routes.Personas
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Braband <ben.brabant@joukou.co>
@author Sebastian Berlein <sebastian.berlein@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.

persona is from greek prosōpon meaning "mask" or "character". Personas are a
legal person (Latin: persona ficta) or a natural person
(Latin: persona naturalis).
###

module.exports = self = new class

  ###*
  @private
  @static
  @property {lodash} _
  ###
  _     = require( 'lodash' )

  ###*
  @private
  @static
  @property {joukou-server.AuthN} AuthN
  ###
  AuthN = require( '../AuthN' )

  ###*
  @private
  @static
  @property {joukou-server.AuthZ} AuthZ
  ###
  AuthZ = require( '../AuthZ' )

  ###*
  @method registerRoutes
  @param {joukou-server.server} server
  ###
  registerRoutes: ( server ) ->
    server.post(
      '/personas',
      AuthN.authenticate,
      self.create.bind( @ )
    )
    server.get(
      '/personas/:personaKey',
      AuthN.authenticate,
      self.show.bind( @ )
    )
    server.post(
      '/personas/:personaKey/agents',
      AuthN.authenticate,
      self.linkToAgents.bind( @ )
    )
    server.get(
      '/personas/:personaKey/agents',
      AuthN.authenticate,
      self.linkedAgentsSearch.bind( @ )
    )
    server.post(  '/personas/:personaKey/personas',
      AuthN.authenticate,
      self.linkToPersonas.bind( @ )
    )
    server.get(
      '/personas/:personaKey/personas',
      AuthN.authenticate,
      self.linkedPersonasSearch.bind( @ )
    )
    server.get(
      '/personas/:personaKey/personas/facets',
      AuthN.authenticate,
      self.linkedPersonasSearchFacets.bind( @ )
    )
    server.get(
      '/personas/:personaKey/personas/terms',
      AuthN.authenticate,
      self.linkedPersonasSearchTerms.bind( @ )
    )

    server.post(
      '/personas/:personaKey/cases',
      AuthN.authenticate,
      self.createCase.bind( @ )
    )
    server.get(
      '/personas/:personaKey/cases/:caseKey',
      AuthN.authenticate,
      self.showCase.bind( @  )
    )
    #server.get(
    # '/personas/:personaKey/cases',
    # auth.authenticate,
    # self.myCases.bind( @ )
    # )
    #server.get(
    # '/personas/:personaKey/personas/cases',
    # auth.authenticate,
    # self.linkedPersonasCases.bind( @ )
    # )

    server.get(
      '/personas/:personaKey/items',
      AuthN.authenticate,
      self.itemsSearch.bind( @ )
    )
    server.get(
      '/personas/:personaKey/items/facets',
      AuthN.authenticate,
      self.itemsSearchFacets.bind( @ )
    )
    server.get(
      '/personas/:personaKey/items/terms',
      AuthN.authenticate,
      self.itemsSearchTerms.bind( @ )
    )

  ###*
  @method create
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  create: ( req, res, next ) ->

  ###*
  @method show
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  show: ( req, res, next ) ->

  ###*
  @method linkToAgents
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkToAgents: ( req, res, next ) ->

  ###*
  @method linkedAgentsSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedAgentsSearch: ( req, res, next ) ->

  ###*
  @method linkedAgentsSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedAgentSearchFacets: ( req, res, next ) ->

  ###*
  @method linkToPersonas
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkToPersonas: ( req, res, next ) ->

  ###*
  @method linkedPersonasSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearch: ( req, res, next ) ->

  ###*
  @method linkedPersonasSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearchFacets: ( req, res, next ) ->

  ###*
  @method linkedPersonasSearchTerms
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  linkedPersonasSearchTerms: ( req, res, next ) ->

  ###*
  @method createCase
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  createCase: ( req, res, next ) ->

  ###*
  @method showCase
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  showCase: ( req, res, next ) ->

  ###*
  @method itemsSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  itemsSearch: ( req, res, next ) ->

  ###*
  @method itemsSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  itemsSearchFacets: ( req, res, next ) ->

  ###*
  @method itemsSearchTerms
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
  ###
  itemsSearchTerms: ( req, res, next ) ->
