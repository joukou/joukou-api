assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()
sinon             = require( 'sinon' )
rewire            = require( 'rewire' )

Q                 = require( 'q' )
schemajs          = require( 'schemajs' )

Model             = rewire( '../../dist/riak/Model' )

describe 'riak/Model', ->

  specify 'is defined', ->
    should.exist( Model )

  describe 'define', ->

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


    describe 'create', ->

      specify 'is defined', ->
        should.exist( TestModel.create )
        TestModel.create.should.be.a( 'function' )

      specify 'calls beforeCreate if it exists', ->
        TestModel.beforeCreate = sinon.stub().returns( Q.fcall( -> name: 'This is a test.' ) )
        TestModel.create( name: 'This is a test.' )
        TestModel.beforeCreate.should.have.been.called

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