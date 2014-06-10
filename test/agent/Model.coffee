assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

bcrypt            = require( 'bcrypt' )
AgentModel        = require( '../../dist/agent/Model' )
NotFoundError     = require( '../../dist/riak/NotFoundError' )
pbc               = require( '../../dist/riak/pbc' )

describe 'agent/Model', ->

  before ( done ) ->
    pbc.put(
      type: 'agent'
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

  specify 'is defined', ->
    should.exist( AgentModel )

  describe '.create( )', ->

    specify 'creates a new agent', ( done ) ->
      AgentModel.create(
        email: 'ben.brabant@joukou.com'
        name: 'Ben Brabant'
        password: 'password'
      ).then( ( agent ) ->
        { email, name, password } = agent.getValue()
        email.should.equal( 'ben.brabant@joukou.com' )
        name.should.equal( 'Ben Brabant' )
        bcrypt.compareSync( 'password', password ).should.be.true
        done()
      ).fail( ( err ) ->
        done( err )
      )

  describe '::save( )', ->

    specify 'persists an agent model instance to Basho Riak', ( done ) ->
      AgentModel.create(
        email: 'ben.brabant@joukou.com'
        name: 'Ben Brabant'
        password: 'password'
      ).then( ( agent ) ->
        agent.save().then( ( saved ) ->
          AgentModel.retrieveByEmail( 'ben.brabant@joukou.com' ).then( ( retrieved ) ->
            retrieved.getName().should.equal( 'Ben Brabant' )
            pbc.del(
              bucket: 'agent'
              key: retrieved.getKey()
            , ( err, reply ) ->
              done()
            )
          ).fail( ( err ) ->
            done( err )
          )
        ).fail( ( err ) ->
          done( err )
        )
      ).fail( ( err ) ->
        done( err )
      )

  describe '.retrieveByEmail( email )', ->

    specify 'is eventually rejected with a NotFoundError if the email does not exist', ->
      AgentModel.retrieveByEmail( 'bogus' ).should.eventually.be.rejectedWith( NotFoundError )

    specify 'is eventually resolved with a Model instance if the email does exist', ->
      AgentModel.retrieveByEmail( 'isaac.johnston@joukou.com' ).then( ( agent ) ->
        agent.getValue().should.deep.equal(
          email: 'isaac.johnston@joukou.com'
          roles: [ 'operator' ]
          name: 'Isaac'
          password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'
        )
      )

  describe '::verifyPassword( password )', ->

    specify 'is eventually resolved with false if the password does not match', ->
      AgentModel.retrieveByEmail( 'isaac.johnston@joukou.com' ).then( ( agent ) ->
        agent.verifyPassword( 'bogus' ).should.eventually.be.equal( false )
      )

    specify 'is eventually resolved with true if the password does match', ->
      AgentModel.retrieveByEmail( 'isaac.johnston@joukou.com' ).then( ( agent ) ->
        agent.verifyPassword( 'password' ).should.eventually.be.equal( true )
      )

  describe '.retrieveByEmail( email )', ->

    specify 'is defined', ->
      should.exist( AgentModel.retrieveByEmail )
      AgentModel.retrieveByEmail.should.be.a( 'function' )

  describe '::getRepresentation', ->

    specify 'is defined', ->
      should.exist( AgentModel::getRepresentation )
      AgentModel::getRepresentation.should.be.a( 'function' )

    specify 'is a representation of the model instance', ->
      instance = new AgentModel(
        value:
          email: 'isaac.johnston@joukou.com'
          name: 'Isaac Johnston'
          roles: [ 'operator' ]
          password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'
      )
      instance.getRepresentation().should.deep.equal(
        email: 'isaac.johnston@joukou.com'
        name: 'Isaac Johnston'
        roles: [ 'operator' ]
      )

  describe '::getEmail', ->

    specify 'is defined', ->
      should.exist( AgentModel::getEmail )
      AgentModel::getEmail.should.be.a( 'function' )

    specify 'is the email of the model instance', ->
      instance = new AgentModel(
        value:
          email: 'isaac.johnston@joukou.com'
          name: 'Isaac Johnston'
          roles: [ 'operator' ]
          password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'
      )
      instance.getEmail().should.equal( 'isaac.johnston@joukou.com' )     

  describe '::getRoles', ->

    specify 'is defined', ->
      should.exist( AgentModel::getRoles )
      AgentModel::getRoles.should.be.a( 'function' )

    specify 'is the array of roles of the model instance', ->
      instance = new AgentModel(
        value:
          email: 'isaac.johnston@joukou.com'
          name: 'Isaac Johnston'
          roles: [ 'operator' ]
          password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'
      )
      instance.getRoles().should.deep.equal( [ 'operator' ] )

  describe '::hasSomeRoles( roles )', ->

    hasSomeRolesInstance = new AgentModel(
      value:
        email: 'isaac.johnston@joukou.com'
        name: 'Isaac Johnston'
        roles: [ 'operator', 'administrator' ]
        password: '$2a$10$JMhLJZ2DZiLMSvfGXHHo2e7jkrONex08eSLaStW15P0SavzyPF5GG'       
    )

    specify 'is defined', ->
      should.exist( AgentModel::hasSomeRoles )
      AgentModel::hasSomeRoles.should.be.a( 'function' )

    specify 'is true when the model instance has at least one of the given roles', ->
      hasSomeRolesInstance.hasSomeRoles( [ 'operator' ] ).should.be.true

    specify 'is true when the model instance has at least one of the given roles but not all of them', ->
      hasSomeRolesInstance.hasSomeRoles( [ 'operator', 'guest' ] ).should.be.true

    specify 'is false when the model instance does not have the given roles', ->
      hasSomeRolesInstance.hasSomeRoles( [ 'superman' ] ).should.be.false
