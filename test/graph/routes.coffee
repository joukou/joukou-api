###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

assert      = require( 'assert' )
chai        = require( 'chai' )
should      = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel  = require( '../../dist/agent/Model' )
GraphModel  = require( '../../dist/graph/Model' )
server      = require( '../../dist/server' )
riakpbc     = require( '../../dist/riak/pbc' )

xdescribe 'graph/routes', ->

  agentKey = null

  before ( done ) ->
    AgentModel.create(
      email: 'test+graph+routes@joukou.com'
      name: 'test/graph/routes'
      password: 'password'
    ).then( ( agent ) ->
      agent.save().then( ->
        agentKey = agent.getKey()
        done()
      ).fail( ( err ) ->
        done( err )
      )
    ).fail( ( err ) ->
      done( err )
    )

  describe 'POST /graph', ->

    specify 'creates a new graph given valid data', ( done ) ->
      chai.request( server )
        .post( '/graph' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
          #req.type( 'json' )
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
          res.headers.location.should.match( /^\/graph\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )
          key = res.headers.location.match( /^\/graph\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]
          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )

              riakpbc.del(
                bucket: 'graph'
                key: key
              , ( err, reply ) ->
                done( err )
              )
            )
        )

  describe 'GET /graph/:key', ->

    specify 'responds with 404 NotFound status code if the provided graph key is not valid', ( done ) ->
      chai.request( server )
        .get( '/graph/7ec23d7d-9522-478c-97a4-2f577335e023' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
        )
        .res( ( res ) ->
          res.should.have.status( 404 )
          res.body.should.be.empty
          done()
        )

  after ( done ) ->
    AgentModel.deleteByEmail( 'test+graph+routes@joukou.com' )
      .then( ->
        done()
      ).fail( ( err ) ->
        done( err )
      )