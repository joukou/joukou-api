assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()
sinon             = require( 'sinon' )
rewire            = require( 'rewire' )

_                 = require( 'lodash' )
Q                 = require( 'q' )
schemajs          = require( 'schemajs' )
Model             = rewire( '../../dist/riak/Model' )

describe 'riak/Model', ->

  specify 'is defined', ->
    should.exist( Model )

  describe '.define()', ->

    testSchema = null
    TestModel = null

    beforeEach ->
      testSchema = schemajs.create(
        name:
          type: 'string+'
      )
      TestModel = Model.define(
        bucket: 'test'
        schema: testSchema
      )

    specify 'is defined', ->
      should.exist( Model.define )
      Model.define.should.be.a( 'function' )

    specify 'creates unique classes on each call', ->
      fruitSchema = schemajs.create(
        name:
          type: 'string+'
      )
      fruit = Model.define(
        bucket: 'fruit'
        schema: fruitSchema
      )

      vegeSchema = schemajs.create(
        name:
          type: 'string+'
      )
      vege = Model.define(
        bucket: 'vege'
        schema: vegeSchema
      )

      fruit.should.not.equal( vege )

      fruit.getBucket().should.equal( 'fruit' )
      vege.getBucket().should.equal( 'vege' )

      fruit.getSchema().should.equal( fruitSchema )
      vege.getSchema().should.equal( vegeSchema )

      fruit.getSchema().should.not.equal( vege.getSchema() )

    specify 'throws TypeError if bucket option is not defined', ->
      fn = _.wrap( Model.define, ( func ) ->
        func( schema: testSchema )
      )
      fn.should.throw( TypeError, /type is not a string/ )

    specify 'throw TypeError if schema option is not defined', ->
      fn = _.wrap( Model.define, ( func ) ->
        func( bucket: 'test-define' )
      )
      fn.should.throw( TypeError, /schema is not a schema object/ )

    describe '.getType()', ->

      specify 'defaults to "default"', ->
        GetTypeModel = Model.define(
          bucket: 'test-getType'
          schema: testSchema
        )
        GetTypeModel.getType().should.equal( 'default' )

      specify 'is the type provided as part of the model definition', ->
        GetTypeModel = Model.define(
          type: 'test-getType'
          bucket: 'test-getType'
          schema: testSchema
        )
        GetTypeModel.getType().should.equal( 'test-getType' )


    describe '.getBucket()', ->

      specify 'is the bucket provided at model definition', ->
        GetBucketModel = Model.define(
          bucket: 'test-getBucket'
          schema: testSchema
        )
        GetBucketModel.getBucket().should.equal( 'test-getBucket' )

    describe '::getValue()', ->

      specify 'is defined', ->
        should.exist( TestModel::getValue )

      specify 'is equivalent to the value provided at model instantiation', ->
        value = {}
        instance = new TestModel(
          value: value
        )
        instance.getValue().should.equal( value )

    describe '::_getPbParams()', ->

      specify 'is defined', ->
        should.exist( TestModel::_getPbParams )
        TestModel::_getPbParams.should.be.a( 'function' )

    describe '::_getSerializedValue()', ->

      specify 'is defined', ->
        should.exist( TestModel::_getSerializedValue )
        TestModel::_getSerializedValue.should.be.a( 'function' )





    describe 'create', ->

      specify 'is defined', ->
        should.exist( TestModel.create )
        TestModel.create.should.be.a( 'function' )

      specify 'calls afterCreate if it exists', ->
        TestModel.afterCreate = sinon.stub().returns( Q.fcall( -> new MetaValue( value: { name: 'This is a test.' } ) ) )
        TestModel.create( name: 'This is a test.' )
        TestModel.afterCreate.should.have.been.called

      xspecify 'creates a value in Basho Riak', ->
        riakOriginal = Model.__get__( 'riak' )

        riak =
          put: ( metaValue ) ->
            Q.fcall( -> metaValue )

        putSpy = sinon().spy( riak, 'put' ) 

        Model.__set__( 'riak', riak )

        TestModel.create( name: 'This is a test.' )

        putSpy.should.have.been.called

        Model.__set__( 'riak', riakOriginal )

  xdescribe 'create', ->

    specify 'should eventually be rejected with an array of any validation errors found', ->
      schema = schemajs.create(
        name:
          type: 'string+'
      )
      model = Model.factory( bucket: 'test', schema: schema )
      model.create(
        name: ''
      ).should.be.rejected