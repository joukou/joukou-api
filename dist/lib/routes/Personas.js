"use strict";

/**
@class joukou-server.routes.Personas
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Brabant <ben.brabant@joukou.co>
@author Sebastian Berlein <sebastian.berlein@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.

persona is from greek prosōpon meaning "mask" or "character". Personas are a
legal person (Latin: persona ficta) or a natural person
(Latin: persona naturalis).
 */
var self;

module.exports = self = new ((function() {

  /**
  @private
  @static
  @property {lodash} _
   */
  var AuthN, AuthZ, _;

  function _Class() {}

  _ = require('lodash');


  /**
  @private
  @static
  @property {joukou-server.AuthN} AuthN
   */

  AuthN = require('../AuthN');


  /**
  @private
  @static
  @property {joukou-server.AuthZ} AuthZ
   */

  AuthZ = require('../AuthZ');


  /**
  @method registerRoutes
  @param {joukou-server.server} server
   */

  _Class.prototype.registerRoutes = function(server) {
    server.post('/personas', AuthN.authenticate, self.create.bind(this));
    server.get('/personas/:personaKey', AuthN.authenticate, self.show.bind(this));
    server.post('/personas/:personaKey/agents', AuthN.authenticate, self.linkToAgents.bind(this));
    server.get('/personas/:personaKey/agents', AuthN.authenticate, self.linkedAgentsSearch.bind(this));
    server.post('/personas/:personaKey/personas', AuthN.authenticate, self.linkToPersonas.bind(this));
    server.get('/personas/:personaKey/personas', AuthN.authenticate, self.linkedPersonasSearch.bind(this));
    server.get('/personas/:personaKey/personas/facets', AuthN.authenticate, self.linkedPersonasSearchFacets.bind(this));
    server.get('/personas/:personaKey/personas/terms', AuthN.authenticate, self.linkedPersonasSearchTerms.bind(this));
    server.post('/personas/:personaKey/cases', AuthN.authenticate, self.createCase.bind(this));
    server.get('/personas/:personaKey/cases/:caseKey', AuthN.authenticate, self.showCase.bind(this));
    server.get('/personas/:personaKey/items', AuthN.authenticate, self.itemsSearch.bind(this));
    server.get('/personas/:personaKey/items/facets', AuthN.authenticate, self.itemsSearchFacets.bind(this));
    return server.get('/personas/:personaKey/items/terms', AuthN.authenticate, self.itemsSearchTerms.bind(this));
  };


  /**
  @method create
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.create = function(req, res, next) {};


  /**
  @method show
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.show = function(req, res, next) {};


  /**
  @method linkToAgents
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkToAgents = function(req, res, next) {};


  /**
  @method linkedAgentsSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkedAgentsSearch = function(req, res, next) {};


  /**
  @method linkedAgentsSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkedAgentSearchFacets = function(req, res, next) {};


  /**
  @method linkToPersonas
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkToPersonas = function(req, res, next) {};


  /**
  @method linkedPersonasSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkedPersonasSearch = function(req, res, next) {};


  /**
  @method linkedPersonasSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkedPersonasSearchFacets = function(req, res, next) {};


  /**
  @method linkedPersonasSearchTerms
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.linkedPersonasSearchTerms = function(req, res, next) {};


  /**
  @method createCase
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.createCase = function(req, res, next) {};


  /**
  @method showCase
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.showCase = function(req, res, next) {};


  /**
  @method itemsSearch
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.itemsSearch = function(req, res, next) {};


  /**
  @method itemsSearchFacets
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.itemsSearchFacets = function(req, res, next) {};


  /**
  @method itemsSearchTerms
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.itemsSearchTerms = function(req, res, next) {};

  return _Class;

})());

/*
//# sourceMappingURL=Personas.js.map
*/
