assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel        = require( '../../dist/agent/Model' )
server            = require( '../../dist/server' )
pbc               = require( '../../dist/riak/pbc' )

describe 'agent/routes', ->

  describe 'POST /agent', ->

    specify 'creates a new agent given valid data', ( done ) ->
      chai.request( server )
        .post( '/agent' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            email: 'test+agent+routes+create@joukou.com'
            name: 'test/agent/routes/create'
            password: 'password'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          res.headers.location.should.match( /^\/agent\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )

          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer( "test+agent+routes+create@joukou.com:password" ).toString( 'base64' )}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )
              done()
            )
        )



  xdescribe 'GET /agent', ->

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