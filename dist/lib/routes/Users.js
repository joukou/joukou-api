"use strict";

/**
@class joukou-api.routes.Users
@author Isaac Johnston <isaac.johnston@joukou.co>
@author Ben Brabant <ben.brabant@joukou.co>
@author Sebastian Berlein <sebastian.berlein@joukou.co>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.

A user is an agent.

An agent is authorized to act on behalf of a persona (called the principal).
By way of a relationship between the principal and an agent the principal
authorizes the agent to work under his control and on his behalf.

Latin: qui facit per alium, facit per se, i.e. the one who acts through
another, acts in his or her own interests.
 */
var jwt, self;

jwt = require('jsonwebtoken');

module.exports = self = new ((function() {

  /**
  @private
  @static
  @property {lodash} _
   */
  var AuthN, AuthZ, UserModel, _;

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
  @private
  @static
  @property {joukou-api.model.User} Model
   */

  UserModel = require('../model/User');


  /**
  @method registerRoutes
  @param {joukou-api.server} server
   */

  _Class.prototype.registerRoutes = function(server) {
    server.post('/users', _.bind(this.create, this));
    server.post('/authenticate', AuthN.authenticate, _.bind(this.authenticate, this));
    server.get('/users/:username', AuthN.authenticate, _.bind(this.show, this));
    server.post('/users/:username/personas', AuthN.authenticate, _.bind(this.linkToPersonas, this));
    server.get('/users/:username/personas', AuthN.authenticate, _.bind(this.linkedPersonasSearch, this));
    return server.get('/users/:username/personas/facets', AuthN.authenticate, _.bind(this.linkedPersonasSearchFacets, this));
  };


  /**
  @method create
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.create = function(req, res, next) {
    return UserModel.create(req.body).save().then(function() {
      return res.send(201);
    }).fail(function(err) {
      return res.send(err);
    });
  };


  /**
  @method authenticate
  @param {http.ClientRequest} req
  @param {http.ServerResponse} res
  @param {Function} next
   */

  _Class.prototype.authenticate = function(req, res, next) {
    var token;
    token = jwt.sign(req.user, 'abc', {
      expiresInMinutes: 60 * 5
    });
    return res.send(200, {
      token: token
    });
  };


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
//# sourceMappingURL=Users.js.map
*/
