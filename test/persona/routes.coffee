assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server            = require( '../../dist/server' )
pbc               = require( '../../dist/riak/pbc' )


xdescribe 'persona/routes', ->

  before ( done ) ->
    pbc.put(
      bucket: 'agent'
      key: '7ec23d7d-9522-478c-97a4-2f577335e023'
      content:
        content_type: 'application/json'
        indexes: [
          {
            key: 'email_bin'
            value: 'isaac.johnston@joukou.com'
          }
        ]
        value: JSON.stringify(
          email: 'isaac.johnston@joukou.com'
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
          req.set( 'Authorization', "Basic #{new Buffer('isaac.johnston@joukou.com:password').toString('base64')}" )
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