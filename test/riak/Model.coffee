assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

schemajs          = require( 'schemajs' )
Model             = require( '../../dist/riak/Model' )


describe 'riak/Model', ->

  specify 'is defined', ->
    should.exist( Model )

  describe 'create', ->

    specify 'should eventually be rejected with an array of any validation errors found', ->
      schema = schemajs.create(
        name:
          type: 'string+'
      )
      model = Model.factory( bucket: 'test', schema: schema )
      model.create(
        name: ''
      ).should.be.rejected