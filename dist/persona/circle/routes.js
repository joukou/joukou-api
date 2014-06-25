"use strict";

/**
{@link module:joukou-api/persona/circle/Model|Circle} APIs provide information
about the available Circles. In future the ability to create, sell and buy
Circles will be added.

@module joukou-api/persona/circle/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
 */
var self;

module.exports = self = {
  registerRoutes: function(server) {
    server.get('/persona/:personaKey/circle', self.index);
  },
  index: function(req, res, next) {
    return res.send(200, {
      _embedded: {
        'joukou:circle': [
          {
            _links: {
              self: {
                href: "/persona/" + req.params.personaKey + "/circle/cdb6bc33-1e8a-46de-8049-3dcf0d8bddec"
              },
              'joukou:persona': {
                href: "/persona/" + req.params.personaKey
              }
            },
            name: 'MySQLQuery',
            description: 'Obtain data from a MySQL database.',
            icon: 'database',
            subgraph: false,
            inports: [
              {
                id: 'query',
                type: 'string',
                description: 'The SELECT query to run against the MySQL database.',
                addressable: false,
                required: true
              }, {
                id: 'hostname',
                type: 'string',
                description: 'The hostname of the MySQL database.',
                addressable: false,
                required: true
              }, {
                id: 'username',
                type: 'string',
                description: 'The username for the MySQL database.',
                addressable: false,
                required: true
              }
            ],
            outports: [
              {
                id: 'data',
                type: 'datum',
                description: 'The rows found by the MySQL query.',
                addressable: false,
                required: true
              }, {
                id: 'error',
                type: 'error',
                description: 'Any errors as a result of connecting to the database or executing the query',
                addressable: false,
                required: false
              }
            ]
          }
        ]
      }
    });
  }
};

/*
//# sourceMappingURL=routes.js.map
*/
