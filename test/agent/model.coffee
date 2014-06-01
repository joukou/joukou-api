assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

model             = require( '../../dist/agent/model' )
NotFoundError     = require( '../../dist/riak/NotFoundError' )
riak              = require( '../../dist/riak/Client' )

describe 'agent/Model', ->

  before ( done ) ->
    riak.put(
      bucket: 'agent'
      key: 'isaac@joukou.com'
      value:
        username: 'isaac@joukou.com'
        roles: [ 'operator' ]
        name: 'Isaac'
        password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG' # "password" in bcrypt w/ 10 rounds
    ).then( ->
      done()
    )

  specify 'is defined', ->
    should.exist( model )

  describe '.retrieve( email )', ->

    specify 'is eventually rejected with a NotFoundError if the username does not exist', ->
      model.retrieve( 'bogus' ).should.eventually.be.rejectedWith( NotFoundError )

    specify 'is eventually resolved with a MetaValue if the username does exist', ->
      model.retrieve( 'isaac@joukou.com' ).then( ( agent ) ->
        agent.getValue().should.deep.equal(
          username: 'isaac@joukou.com'
          roles: [ 'operator' ]
          name: 'Isaac'
          password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'
        )
      )

  describe '::verifyPassword( password )', ->

    specify 'is eventually resolved with false if the password does not match', ->
      model.retrieve( 'isaac@joukou.com' ).then( ( agent ) ->
        agent.verifyPassword( 'bogus' ).should.eventually.be.equal( false )
      )

    specify 'is eventually resolved with true if the password does match', ->
      model.retrieve( 'isaac@joukou.com' ).then( ( agent ) ->
        agent.verifyPassword( 'password' ).should.eventually.be.equal( true )
      )


