assert          = require( 'assert' )
chai            = require( 'chai' )
chaiAsPromised  = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should          = chai.should()

AbstractModel   = require( '../../dist/lib/model/Abstract' )
UserSchema      = require( '../../dist/lib/schema/User' )

describe 'model.Abstract', ->

  specify 'is defined', ->
    AbstractModel.should.be.defined

  describe 'exists', ->

    specify 'is defined', ->
      AbstractModel::exists.should.be.defined

    xspecify 'eventually is boolean false if the given key does not exist in the model\'s configured bucket', ->
      model = new AbstractModel( bucket: 'test', schema: UserSchema )
      model.exists( 'bogus' ).should.eventually.be.false