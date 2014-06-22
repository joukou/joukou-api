"use strict"

module.exports = self =

  registerRoutes: ( server ) ->
    server.get( '/persona/:personaKey/circle', self.index )
    return

  index: ( req, res, next ) ->
    res.send( 200,
      _embedded:
        'joukou:circle': [
          {
            name: 'MySQLQuery'
            description: 'Obtain data from a MySQL database.'
            icon: 'database'
            subgraph: false
            inPorts: [
              {
                id: 'query'
                type: 'string'
                description: 'The SELECT query to run against the MySQL database.'
                addressable: false
                required: true
              }
              {
                id: 'hostname'
                type: 'string'
                description: 'The hostname of the MySQL database.'
                addressable: false
                required: true
              }
              {
                id: 'username'
                type: 'string'
                description: 'The username for the MySQL database.'
                addressable: false
                required: true
              }
            ]
            outPorts: [
              {
                id: 'data'
                type: 'datum'
                description: 'The rows found by the MySQL query.'
                addressable: false
                required: true
              }
              {
                id: 'error'
                type: 'error'
                description: 'Any errors as a result of connecting to the database or executing the query'
                addressable: false
                required: false
              }
            ]
          }
        ]
    )