assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel        = require( '../../dist/agent/Model' )
server            = require( '../../dist/server' )
pbc               = require( '../../dist/riak/pbc' )

describe 'agent/routes', ->

  describe 'POST /agent', ->

    xspecify 'creates a new agent given valid data', ( done ) ->
      chai.request( server )
        .post( '/agent' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('isaac.johnston@joukou.com:password').toString('base64')}" )
          req.type( 'json' )
          #req.accept( 'application/hal+json' )
          req.send(
            email: 'sebastian.berlein@joukou.com'
            name: 'Sebastian Berlein'
            password: 'password'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )

  describe 'GET /agent', ->

    agentKey = null

    before ( done ) ->
      AgentModel.create(
        email: 'sebastian.berlein@joukou.com'
        name: 'Sebastian Berlein'
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

    specify 'shows the agent identified by the provided key', ( done ) ->
      chai.request( server )
        .get( "/agent/#{agentKey}" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('isaac.johnston@joukou.com:password').toString('base64')}" )
        )
        .res( ( res ) ->
          res.should.have.status( 200 )
          done()
        )

    after ( done ) ->
      pbc.del(
        bucket: 'agent'
        key: agentKey
      , ( err, reply ) ->
        done( err )
      )