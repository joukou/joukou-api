"use strict"

###*
{@link module:joukou-api/persona/circle/Model|Circle} APIs provide information
about the available Circles. In future the ability to create, sell and buy
Circles will be added.

@module joukou-api/persona/circle/routes
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright &copy; 2009-2014 Joukou Ltd. All rights reserved.
###

module.exports = self =

  registerRoutes: ( server ) ->
    server.get( '/persona/:personaKey/circle', self.index )
    return

  index: ( req, res, next ) ->
    res.send( 200,
      _embedded:
        'joukou:circle': [
          {
            _links:
              self:
                href: "/persona/#{req.params.personaKey}/circle/cdb6bc33-1e8a-46de-8049-3dcf0d8bddec"
              'joukou:persona':
                href: "/persona/#{req.params.personaKey}"
            name: 'MySQL Query'
            description: 'Obtain data from a MySQL database.'
            icon: 'database'
            subgraph: false
            inports: [
              {
                id: 'query'
                name: 'query'
                type: 'string'
                description: 'The SELECT query to run against the MySQL database.'
                addressable: false
                required: true
              }
              {
                id: 'hostname'
                name: 'hostname'
                type: 'string'
                description: 'The hostname of the MySQL database.'
                addressable: false
                required: true
              }
              {
                id: 'username'
                name: 'username'
                type: 'string'
                description: 'The username for the MySQL database.'
                addressable: false
                required: true
              }
            ]
            outports: [
              {
                id: 'data'
                name: 'data'
                type: 'datum'
                description: 'The rows found by the MySQL query.'
                addressable: false
                required: true
              }
              {
                id: 'error'
                name: 'error'
                type: 'error'
                description: 'Any errors as a result of connecting to the database or executing the query'
                addressable: false
                required: false
              }
            ]
          }
          {
            _links:
              self:
                href: "/persona/#{req.params.personaKey}/circle/bafbf2f8-0dc4-4ae5-85ec-00aea219fed6"
              'joukou:persona':
                href: "/persona/#{req.params.personaKey}"
            name: 'Publish Search API'
            description: 'Publish a search API.'
            icon: 'search'
            subgraph: false
            inports: [
              {
                id: 'data'
                name: 'data'
                type: 'datum'
                description: 'The data to index for searching'
                addressable: false
                required: true
              }
            ]
            outports: [
              {
                id: 'endpoint'
                name: 'endpoint'
                type: 'string'
                description: 'The URL of the search API endpoint'
                addressable: false
                required: true
              }
              {
                id: 'err'
                name: 'err'
                type: 'error'
                description: 'Any errors'
                addressable: false
                required: true
              }
            ]
          }
        ]
    )