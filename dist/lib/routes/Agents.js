"use strict";

/**
@class joukou-api.routes.Agents
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Braband <ben.brabant@joukou.co>
@author Sebastian Berlein <sebastian.berlein@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.

An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.
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
  @property {joukou-api.AuthN} AuthN
   */

  AuthN = require('../AuthN');


  /**
  @private
  @static
  @property {joukou-api.AuthZ} AuthZ
   */

  AuthZ = require('../AuthZ');


  /**
  @method registerRoutes
  @param {joukou-api.server} server
   */

  _Class.prototype.registerRoutes = function(server) {
    server.post('/agents', _.bind(this.create, this));
    server.post('/agents/authenticate', AuthN.authenticate, _.bind(this.authenticate, this));
    server.get('/agents/:agentKey', AuthN.authenticate, _.bind(this.show, this));
    server.post('/agents/:agentKey/personas', AuthN.authenticate, _.bind(this.linkToPersonas, this));
    server.get('/agents/:agentKey/personas', AuthN.authenticate, _.bind(this.linkedPersonasSearch, this));
    return server.get('/agents/:agentKey/personas/facets', AuthN.authenticate, _.bind(this.linkedPersonasSearchFacets, this));
  };


  /**
  @method create
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.create = function(req, res, next) {};


  /**
  @method authenticate
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.authenticate = function(req, res, next) {};


  /**
  @method show
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.show = function(req, res, next) {};


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

  return _Class;

})());

/*
//# sourceMappingURL=Agents.js.map
*/
