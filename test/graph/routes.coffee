assert      = require( 'assert' )
chai        = require( 'chai' )
should      = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel  = require( '../../dist/agent/Model' )
GraphModel  = require( '../../dist/graph/Model' )
server      = require( '../../dist/server' )
riakpbc     = require( '../../dist/riak/pbc' )

xdescribe 'graph/routes', ->

  before ( done ) ->
    AgentModel.create(
      email: 'test+graph+routes@joukou.com'
      name: 'test/graph/routes'
      password: 'password'
    ).then( ->
      done()
    ).fail( ( err ) ->
      done( err )
    )

  xdescribe 'POST /graph', ->

    specify 'creates a new graph given valid data', ( done ) ->
      chai.request( server )
        .post( '/graph' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
          req.type( 'json' )
          req.send(
            properties:
              name: 'MySQL to CSV'
            processes:
              'Query Database':
                component: 'MySQLQuery'
              'CSV':
                component: 'ToCsv'
            connections: [
              {
                src:
                  process: 'Query Database'
                  port: 'out'
                tgt:
                  process: 'CSV'
                  port: 'in'
              }
            ]
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )

  after ( done ) ->
    AgentModel.deleteByEmail( 'test+graph+routes@joukou.com' )
      .then( ->
        done()
      ).fail( ( err ) ->
        done( err )
      )