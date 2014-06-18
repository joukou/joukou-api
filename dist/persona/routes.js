"use strict";

/**
{@link module:joukou-api/personas/Model|Persona} routes.

@module joukou-api/persona/routes
@requires lodash
@requires joukou-api/authn
@requires joukou-api/authz
@requires joukou-api/persona/Model
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
 */
var PersonaModel, async, authn, authz, request, self, _;

_ = require('lodash');

async = require('async');

authn = require('../authn');

authz = require('../authz');

request = require('request');

PersonaModel = require('./Model');

module.exports = self = {

  /**
  Register `/persona` routes with the `server`.
  @param {joukou-api/server} server
   */
  registerRoutes: function(server) {
    server.get('/persona', authn.authenticate, self.index);
    server.post('/persona', authn.authenticate, self.create);
    server.get('/persona/:key', authn.authenticate, self.retrieve);
  },

  /*
  @api {get} /persona Get the list of Joukou Personas that you have access to
  @apiName Persona Index
  @apiGroup Persona
   */
  index: function(req, res, next) {
    return request({
      uri: 'http://localhost:8098/mapred',
      method: 'POST',
      json: {
        inputs: {
          module: 'yokozuna',
          "function": 'mapred_search',
          arg: ['persona', 'agents.key:' + req.user.getKey()]
        },
        query: [
          {
            map: {
              language: 'javascript',
              keep: true,
              source: (function(value, keyData, arg) {
                var result;
                result = Riak.mapValuesJson(value)[0];
                result.key = value.key;
                return [result];
              }).toString()
            }
          }
        ]
      }
    }, function(err, reply) {
      var representation;
      if (err) {
        res.send(503);
        return;
      }
      representation = {};
      representation._embedded = _.reduce(reply.body, function(memo, persona) {
        memo['joukou:persona'].push({
          name: persona.name,
          _links: {
            self: {
              href: "/persona/" + persona.key
            },
            'joukou:agent': _.map(persona.agents, function(agent) {
              return {
                href: "/agent/" + agent.key,
                role: agent.role
              };
            })
          }
        });
        return memo;
      }, {
        'joukou:persona': []
      });
      res.link('/persona', 'joukou:persona-create', {
        title: 'Create a Persona'
      });
      return res.send(200, representation);
    });
  },

  /*
  @api {post} /persona Create a Joukou Persona
  @apiName Create Persona
  @apiGroup Persona
  
  @apiParam {String} name The name of the Persona; e.g. the company name.
  @apiParam {Object.<String,Array>} _links Contains links to other resources.
  
  @apiExample CURL Example:
    curl -i -X POST https://api.joukou.com/persona \
      -H 'Authorization: Basic aXNhYWMuam9obnN0b25Aam91a291LmNvbTpwYXNzd29yZA=='
      -H 'Content-Type: application/json' \
      --data-binary @persona.json
  
  @apiExample persona.json
    {
      "name": "Joukou Ltd",
      "_links": {
        "curies": [
          {
            "name": "joukou",
            "href": "https://rels.joukou.com/{rel}",
            "templated": true
          }
        ],
        "joukou:agent": [
          {
            "href": "/agent/8a549b6d-70c9-40b1-a482-d11e36b780b3",
            "role": "admin"
          }
        ]
      }
    }
  
  @apiSuccess (201) Created The Persona has been created successfully.
  @apiError (429) TooManyRequests The client has sent too many requests in a given amount of time.
  @apiError (503) ServiceUnavailable There was a temporary failure creating the Persona, the client should try again later.
   */

  /**
  Handles a request to create a new *persona*.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  create: function(req, res, next) {
    var data, err, link, links, match, rel, _i, _len, _ref, _ref1;
    data = {};
    data.name = req.body.name;
    data.agents = [];
    try {
      if (req.body._links) {
        _ref = req.body._links;
        for (rel in _ref) {
          links = _ref[rel];
          if (!(rel === 'curies' || rel === 'joukou:agent')) {
            throw new restify.ForbiddenError('link relation types must be "curies" or "joukou:agent"');
          }
          if (_.isObject(links)) {
            links = [links];
          }
          if (!_.isArray(links)) {
            throw new restify.ForbiddenError('link values must be a Link Object or an array of Link Objects');
          }
          if (rel === 'joukou:agent') {
            for (_i = 0, _len = links.length; _i < _len; _i++) {
              link = links[_i];
              if (!(link.href && _.isString(link.href))) {
                throw new restify.ForbiddenError('Link Objects must have a href property');
              }
              match = link.href(/^\/agent\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/);
              if (!match) {
                throw new restify.ForbiddenError('joukou:agent Link Objects must have a href property that is a server-relative URI to an agent resource');
              }
              if (!(link.role && _.isString(link.role))) {
                throw new restify.ForbiddenError('joukou:agent Link Objects must have a role property');
              }
              if ((_ref1 = link.role) !== 'admin') {
                throw new restify.ForbiddenError('joukou:agent Link Objects role property may only be "admin" at this time');
              }
              data.agents.push({
                key: match[1],
                role: link.role
              });
            }
          }
        }
      }
    } catch (_error) {
      err = _error;
      next(err);
      return;
    }
    data.agents.push({
      key: req.user.getKey(),
      role: 'creator'
    });
    return PersonaModel.create(data).then(function(persona) {
      return persona.save().then(function(reply) {
        self = "/persona/" + (persona.getKey());
        res.link(self, 'joukou:persona');
        res.header('Location', self);
        return res.send(201, {});
      }).fail(function(err) {
        return next(err);
      });
    }).fail(function(err) {
      return next(err);
    });
  },

  /*
  @api {get} /persona/:key Retrieve a Joukou Persona
  @apiName Retrieve Persona
  @apiGroup Persona
   */

  /**
  Handles a request to retrieve a certain *persona's* details.
  @param {http.IncomingMessage} req
  @param {http.ServerResponse} res
  @param {function(Error)} next
   */
  retrieve: function(req, res, next) {
    return PersonaModel.retrieve(req.params.key).then(function(persona) {
      var agent, _i, _len, _ref;
      _ref = persona.getValue().agents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        agent = _ref[_i];
        res.link("/agent/" + agent.key, 'joukou:agent', {
          role: agent.role
        });
        res.link("/persona/" + (persona.getKey()) + "/graph", 'joukou:graphs', {
          title: "List of Graphs for " + (persona.getName())
        });
        res.link("/persona/" + (persona.getKey()) + "/graph", 'joukou:graph-create', {
          title: "Create a Graph for " + (persona.getName())
        });
      }
      return res.send(200, _.pick(persona.getValue(), ['name']));
    }).fail(function(err) {
      return next(err);
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
