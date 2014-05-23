assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

model             = require( '../../dist/agent/model' )
{ NotFoundError } = require( 'restify' )
riak              = require( '../../dist/riak/Client' )

xdescribe 'agent/model', ->

  before ->
    riak.put(
      bucket: 'agent'
      key: 'isaac@joukou.com'
      value:
        username: 'isaac@joukou.com'
        roles: [ 'operator' ]
        name: 'Isaac'
        password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG' # "password" in bcrypt w/ 10 rounds
    )

  specify 'is defined', ->
    should.exist( model )

  specify 'is eventually rejected with a NotFoundError if the username does not exist', ->
    model.load( 'bogus' ).should.eventually.be.rejectedWith( NotFoundError )

  specify 'is eventually resolved with a Value if the username does exist', ->
    model.load( 'isaac@joukou.com' ).then( ( agent ) ->
      agent.getValue().should.deep.equal(
        username: 'isaac@joukou.com'
        roles: [ 'operator' ]
        name: 'Isaac'
        password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'
      )
    )