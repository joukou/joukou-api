assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

model             = require( '../../dist/agent/model' )
{ NotFoundError } = require( 'restify' )

describe 'agent/model', ->

  specify 'is defined', ->
    should.exist( model )

  specify 'is eventually rejected with a NotFoundError if the username does not exist', ->
    model.load( 'bogus' ).should.eventually.be.rejectedWith( NotFoundError )