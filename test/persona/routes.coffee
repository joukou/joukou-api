assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server            = require( '../../dist/server' )
pbc               = require( '../../dist/riak/pbc' )


describe 'persona/routes', ->

  before ( done ) ->
    pbc.put(
      bucket: 'agent'
      key: 'isaac@joukou.com'
      content:
        content_type: 'application/json'
        value: JSON.stringify(
          username: 'isaac@joukou.com'
          roles: [ 'operator' ]
          name: 'Isaac'
          password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG' # "password" in bcrypt w/ 10 rounds
        )
    , ( err, reply ) ->
      done( err )
    )

  describe 'POST /persona', ->

    specify 'creates a new persona given valid data', ->
      chai.request( server )
        .post( '/persona' )
        .req( ( req ) ->
          req.set( 'Authorization', 'Basic aXNhYWNAam91a291LmNvbTpwYXNzd29yZA==' )
          req.send(
            name: 'Joukou Ltd'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
        )

  after ( done ) ->
    server.once( 'close', done )
    server.close()