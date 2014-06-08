assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel        = require( '../../dist/agent/Model' )
server            = require( '../../dist/server' )
riakpbc               = require( '../../dist/riak/pbc' )

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

          key = res.headers.location.match( /^\/agent\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]

          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer( "test+agent+routes+create@joukou.com:password" ).toString( 'base64' )}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )

              riakpbc.del(
                bucket: 'agent'
                key: key
              , ( err ,reply ) ->
                done( err )
              )
            )
        )


  describe 'GET /agent', ->
  
    key = null

    before ( done ) ->
      AgentModel.create(
        email: 'test+agent+routes+retrieve@joukou.com'
        name: 'test/agent/routes/retrieve'
        password: 'password'
      ).then( ( agent ) ->
        agent.save().then( ->
          key = agent.getKey()
          done()
        ).fail( ( err ) ->
          done( err )
        )
      ).fail( ( err ) ->
        done( err )
      )

    specify 'retrieves the agent identified by the given key', ( done ) ->
      chai.request( server )
        .get( "/agent/#{key}" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer( 'test+agent+routes+retrieve@joukou.com:password' ).toString( 'base64' )}")
        )
        .res( ( res ) ->
          res.should.have.status( 200 )
          done()
        )

    after ( done ) ->
      riakpbc.del(
        bucket: 'agent'
        key: key
      , ( err, reply ) ->
        done( err )
      )