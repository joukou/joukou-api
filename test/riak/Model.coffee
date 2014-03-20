###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

assert            = require( 'assert' )
chai              = require( 'chai' )
chai.use( require( 'chai-as-promised' ) )
should            = chai.should()
sinon             = require( 'sinon' )
rewire            = require( 'rewire' )

_                 = require( 'lodash' )
Q                 = require( 'q' )
pbc               = require( '../../dist/riak/pbc' )
schemajs          = require( 'schemajs' )
Model             = require( '../../dist/riak/Model' )
{ NotFoundError } = require( 'restify' )

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

    describe '.getSchema()', ->

      specify 'is the schema object provided at model definition', ->
        GetSchemaModel = Model.define(
          bucket: 'test-getSchema'
          schema: testSchema
        )
        GetSchemaModel.getSchema().should.equal( testSchema )

    describe '._expandContentType( type )', ->

      specify 'is defined', ->
        should.exist( TestModel._expandContentType )
        TestModel._expandContentType.should.be.a( 'function' )

      specify 'is image/jpeg given jpeg', ->
        TestModel._expandContentType( 'jpeg' ).should.be.equal( 'image/jpeg' )

      specify 'is image/gif given gif', ->
        TestModel._expandContentType( 'gif' ).should.be.equal( 'image/gif' )

      specify 'is image/png given png', ->
        TestModel._expandContentType( 'png' ).should.be.equal( 'image/png' )

    describe '.create( rawValue )', ->

      specify 'is defined', ->
        should.exist( TestModel.create )
        TestModel.create.should.be.a( 'function' )

      specify 'calls afterCreate if it exists', ->
        TestModel.afterCreate = sinon.stub().returns( Q.fcall( -> new TestModel( value: { name: 'This is a test.' } ) ) )
        TestModel.create( name: 'This is a test.' )
        TestModel.afterCreate.should.have.been.called

      specify 'is eventually rejected with an array of validation errors given a value that does not conform to the schema', ->
        CreateModel = Model.define(
          bucket: 'test-create'
          schema: schemajs.create(
            name:
              type: 'string+'
          )
        )
        CreateModel.create(
          name: ''
        ).should.be.rejected

      specify 'creates a model instance', ->
        CreateModel = Model.define(
          bucket: 'test-create'
          schema: schemajs.create(
            name:
              type: 'string+'
          )
        )
        CreateModel.create(
          name: 'Isaac Johnston'
        ).should.eventually.be.an.instanceof( CreateModel )

      specify 'creates a model instance with an auto-generated key and a filtered value', ( done ) ->
        CreateModel = Model.define(
          bucket: 'test-create'
          schema: schemajs.create(
            name:
              type: 'string+'
              filters: [ 'trim' ]
          )
        )
        CreateModel.create(
          name: ' Isaac Johnston '
        ).then( ( instance ) ->
          instance.getKey().should.be.a( 'string' )
          instance.getKey().should.be.length( 36 )
          instance.getValue().should.deep.equal(
            name: 'Isaac Johnston'
          )
          done()
        ).fail( ( err ) ->
          done( err )
        )

    describe '.createFromReply( { key, reply } )', ->

      specify 'is defined', ->
        should.exist( TestModel.createFromReply )
        TestModel.createFromReply.should.be.a( 'function' )

    describe '.retrieve( key )', ->
      
      before ( done ) ->
        pbc.put(
          bucket: 'test-retrieve'
          key: 'bob_marley'
          content:
            content_type: 'application/json'
            value: JSON.stringify(
              future: 'In this bright future you can\'t forget your past.'
              free: 'None but ourselves can free our minds.'
            )
        , ( err, reply ) ->
          done()
        )

      specify 'is defined', ->
        should.exist( TestModel.retrieve )
        TestModel.retrieve.should.be.a( 'function' )

      specify 'is eventually rejected with a NotFoundError if the bucket/key location does not exist', ->
        RetrieveModel = Model.define(
          bucket: 'test-retrieve'
          schema: schemajs.create(
            future:
              type: 'string+'
            free:
              type: 'string+'
          )
        )

        RetrieveModel.retrieve( 'nonexistent' )
          .should.eventually.be.rejectedWith( NotFoundError )

      specify 'is eventually resolved with a model instance if the bucket/key location does exist', ->
        RetrieveModel = Model.define(
          bucket: 'test-retrieve'
          schema: schemajs.create(
            future:
              type: 'string+'
            free:
              type: 'string+'
          )
        )

        RetrieveModel.retrieve( 'bob_marley' ).then( ( instance ) ->
          should.exist( instance )
          instance.should.be.an.instanceof( RetrieveModel )
          instance.getValue().should.deep.equal(
            future: 'In this bright future you can\'t forget your past.'
            free: 'None but ourselves can free our minds.'
          )
        )

      after ( done ) ->
        pbc.del( { bucket: 'test-retrieve', key: 'bob_marley' }, ( err, reply ) ->
          done()
        )

    describe '.retrieveBySecondaryIndex( index, key, firstOnly )', ->

      specify 'is defined', ->
        should.exist( TestModel.retrieveBySecondaryIndex )
        TestModel.retrieveBySecondaryIndex.should.be.a( 'function' )

    describe '.delete( key )', ->

      specify 'is defined', ->
        should.exist( TestModel.delete )
        TestModel.delete.should.be.a( 'function' )

      specify 'deletes the value from Basho Riak by the given key', ( done ) ->
        TestModel.create( name: 'test-delete' ).then( ( instance ) ->
          TestModel.delete( instance.getKey() ).then( ->
            pbc.get(
              bucket: 'test'
              key: instance.getKey()
            , ( err, reply ) ->
              should.not.exist( err )
              reply.should.be.empty
              done()
            )
          ).fail( ( err ) ->
            done( err )
          )
        ).fail( ( err ) ->
          done( err )
        )

    describe '::getKey()', ->

      specify 'is defined', ->
        should.exist( TestModel::getKey )
        TestModel::getKey.should.be.a( 'function' )

      specify 'is the key provided at model instantiation', ->
        instance = new TestModel(
          key: 'be7a80df-b88c-4b3f-b740-f17962aa9114'
          value: 'getKey test'
        )
        instance.getKey().should.be.equal( 'be7a80df-b88c-4b3f-b740-f17962aa9114' ) 

    describe '::getValue()', ->

      specify 'is defined', ->
        should.exist( TestModel::getValue )

      specify 'is the value provided at model instantiation', ->
        value = {}
        instance = new TestModel(
          value: value
        )
        instance.getValue().should.equal( value )

    describe '::setValue( value )', ->

      specify 'is defined', ->
        should.exist( TestModel::setValue )
        TestModel::setValue.should.be.a( 'function' )

      specify 'sets the value of the model instance', ->
        instance = new TestModel(
          value: 'One'
        )
        instance.setValue( 'Two')
        instance.getValue().should.not.be.equal( 'One' )
        instance.getValue().should.be.equal( 'Two' )

    describe '::save()', ->

      specify 'is defined', ->
        should.exist( TestModel::save )
        TestModel::save.should.be.a( 'function' )

      specify 'persists a value to Basho Riak', ( done ) ->
        SaveModel = Model.define(
          bucket: 'test-save'
          schema: schemajs.create(
            name: 
              type: 'string+'
          )
        )
        SaveModel.create(
          name: 'Isaac Johnston'
        ).then( ( instance ) ->
          instance.save().then( ( saved ) ->
            # Test the model representation of the reply from Basho Riak
            saved.getKey().should.be.a( 'string' )
            saved.getKey().should.be.length( 36 )
            saved.lastMod.should.be.a( 'number' )
            saved.lastModUsecs.should.be.a( 'number' )
            saved.value.should.deep.equal(
              name: 'Isaac Johnston'
            )
            saved.vclock.should.be.an.instanceof( Buffer )
            saved.vtag.should.be.a( 'string' )
            saved.indexes.should.be.a( 'array' )

            # Double check that the value was actually persisted in Basho Riak
            pbc.get(
              bucket: 'test-save'
              key: saved.getKey()
            , ( err, reply ) ->
              should.not.exist( err )
              reply.content[0].content_type.should.be.equal( 'application/json' )
              reply.content[0].value.should.deep.equal(
                name: 'Isaac Johnston'
              )
              reply.content[0].vtag.should.equal( saved.vtag )
              reply.content[0].last_mod.should.equal( saved.lastMod )
              
              # Delete the value from Basho Riak
              pbc.del(
                bucket: 'test-save'
                key: saved.getKey()
              , ( err, reply ) ->
                done()
              )
            )
          ).fail( ( err ) ->
            done( err )
          )
        ).fail( ( err ) ->
          done( err )
        )

    describe '::_getPbParams()', ->

      specify 'is defined', ->
        should.exist( TestModel::_getPbParams )
        TestModel::_getPbParams.should.be.a( 'function' )

      specify 'is the params object representing the model instance that is suitable for sending to Basho Riak via the protocol buffers API', ( done ) ->
        ParamsModel = Model.define(
          bucket: 'test-getPbParams'
          schema: schemajs.create(
            name:
              type: 'string+'
          )
        )
        ParamsModel.create(
          name: 'Isaac Johnston'
        ).then( ( instance ) ->
          instance._getPbParams().should.deep.equal(
            type: 'default'
            bucket: 'test-getPbParams'
            key: instance.getKey()
            return_body: true
            content:
              value: '{"name":"Isaac Johnston"}'
              content_type: 'application/json'
          )
          done()
        ).fail( ( err ) ->
          done( err )
        )

    describe '::_getSerializedValue()', ->

      specify 'is defined', ->
        should.exist( TestModel::_getSerializedValue )
        TestModel::_getSerializedValue.should.be.a( 'function' )

      specify 'is stringified JSON when contentType is application/json', ->
        instance = new TestModel(
          value:
            json: ' is useful'
        )
        instance._getSerializedValue().should.equal( '{"json":" is useful"}' )

    describe '::getContentType()', ->

      specify 'is defined', ->
        should.exist( TestModel::getContentType )
        TestModel::getContentType.should.be.a( 'function' )

      specify 'is the value of contentType', ->
        instance = new TestModel(
          contentType: 'application/joukou'
        ) 
        instance.getContentType().should.be.equal( 'application/joukou' )

    describe '::_detectContentType()', ->

      specify 'is defined', ->
        should.exist( TestModel::_detectContentType )
        TestModel::_detectContentType.should.be.a( 'function' )

      specify 'is the value of contentType if contentType is set and is not a recognized shorthand', ->
        instance = new TestModel(
         contentType: 'application/joukou'
        )
        instance._detectContentType().should.be.equal( 'application/joukou' )

      specify 'is application/octet-stream if contentType is not set and value is an instanceof Buffer', ->
        instance = new TestModel(
          value: new Buffer('')
        )
        instance._detectContentType().should.be.equal( 'application/octet-stream' )

      specify 'is application/json if contentType is not set and value is an object', ->
        instance = new TestModel(
          value: {}
        )
        instance._detectContentType().should.be.equal( 'application/json' )

      specify 'is text/plain if contentType is not set and value is a string', ->
        instance = new TestModel(
          value: ''
        )
        instance._detectContentType().should.be.equal( 'text/plain' )

    describe '::addSecondaryIndex( key )', ->

      specify 'is defined', ->
        should.exist( TestModel::addSecondaryIndex )
        TestModel::addSecondaryIndex.should.be.a( 'function' )

      specify 'adds the given key to the list of secondary indexes', ( done ) ->
        IndexModel = Model.define(
          bucket: 'test-addSecondaryIndex'
          schema: schemajs.create(
            name:
              type: 'string+'
          )
        )
        IndexModel.create(
          name: 'Isaac Johnston'
        ).then( ( instance ) ->
          instance.addSecondaryIndex( 'name' )
          instance.indexes.should.deep.equal(
            [ 'name' ]
          )
          done()
        ).fail( ( err ) ->
          done( err )
        )

    describe '::_getSecondaryIndexes', ->

      specify 'is defined', ->
        should.exist( TestModel::_getSecondaryIndexes )
        TestModel::_getSecondaryIndexes.should.be.a( 'function' )        

      specify 'is an array of secondary index definitions suitable for sending to Basho Riak via the protocol buffers API', ( done ) ->
        IndexModel = Model.define(
          bucket: 'test-_getSecondaryIndexes'
          schema: schemajs.create(
            name:
              type: 'string+'
          )
        )
        IndexModel.create(
          name: 'Isaac Johnston'
        ).then( ( instance ) ->
          instance.addSecondaryIndex( 'name' )
          instance._getSecondaryIndexes().should.deep.equal(
            [
              {
                key: 'name_bin'
                value: 'Isaac Johnston'
              }
            ]
          )
          done()
        ).fail( ( err ) ->
          done( err )
        )