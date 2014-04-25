assert          = require( 'assert' )
chai            = require( 'chai' )
chaiAsPromised  = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should          = chai.should()

UserModel       = require( '../../dist/lib/model/User' )

{ NotFoundError } = require( 'restify' )

describe 'model.User', ->

  specify 'is defined', ->
    UserModel.should.be.defined

  describe 'load', ->

    specify 'is defined', ->
      UserModel.load.should.be.defined

    specify 'is eventually rejected with a NotFoundError if the username does not exist', ->
      UserModel.load( 'bogus' ).should.eventually.be.rejectedWith( NotFoundError )  

