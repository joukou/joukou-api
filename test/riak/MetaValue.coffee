assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

MetaValue         = require( '../../dist/riak/MetaValue' )

describe 'riak/MetaValue', ->

  specify 'is defined', ->
    should.exist( MetaValue )

  describe 'getValue', ->

    specify 'is defined', ->
      should.exist( MetaValue::getValue )
      MetaValue::getValue.should.be.a( 'function' )

    specify 'is equal to value', ->
      value = {}
      metaValue = new MetaValue(
        value: value
      )
      metaValue.getValue().should.equal( value )

  describe 'getModel', ->

    specify 'is defined', ->
      should.exist( MetaValue::getModel )
      MetaValue::getModel.should.be.a( 'function' )

    specify 'is equal to model', ->
      metaValue = new MetaValue()
      model = {}
      metaValue.model = model
      metaValue.getModel().should.equal( model )

  describe 'setModel', ->
  
    specify 'is defined', ->
      should.exist( MetaValue::setModel )
      MetaValue::setModel.should.be.a( 'function' )

    specify 'sets the model', ->
      metaValue = new MetaValue()
      model = {}
      metaValue.setModel( model )
      metaValue.model.should.equal( model )

  describe 'getParams', ->

    specify 'is defined', ->
      should.exist( MetaValue::getParams )
      MetaValue::getParams.should.be.a( 'function' )

  describe 'getSerializedValue', ->

    specify 'is defined', ->
      should.exist( MetaValue::getSerializedValue )
      MetaValue::getSerializedValue.should.be.a( 'function' )

    specify 'is stringified JSON when contentType is application/json', ->
      metaValue = new MetaValue(
        value:
          json: 'is useful'
      )
      metaValue.getSerializedValue().should.equal( '{"json":"is useful"}' )

  describe '_detectContentType', ->

    specify 'is defined', ->
      should.exist( MetaValue::_detectContentType )
      MetaValue::_detectContentType.should.be.a( 'function' )

    specify 'is the value of contentType if contentType is set and is not a recognized shorthand', ->
      metaValue = new MetaValue(
       contentType: 'application/joukou'
      )
      metaValue._detectContentType().should.be.equal( 'application/joukou' )

    specify 'is application/octet-stream if contentType is not set and value is an instanceof Buffer', ->
      metaValue = new MetaValue(
        value: new Buffer('')
      )
      metaValue._detectContentType().should.be.equal( 'application/octet-stream' )

    specify 'is application/json if contentType is not set and value is an object', ->
      metaValue = new MetaValue(
        value: {}
      )
      metaValue._detectContentType().should.be.equal( 'application/json' )

    specify 'is text/plain if contentType is not set and value is a string', ->
      metaValue = new MetaValue(
        value: ''
      )
      metaValue._detectContentType().should.be.equal( 'text/plain' )

  describe '_expandContentType', ->

    specify 'is defined', ->
      should.exist( MetaValue::_expandContentType )
      MetaValue::_expandContentType.should.be.a( 'function' )

    specify 'is image/jpeg given jpeg', ->
      MetaValue::_expandContentType( 'jpeg' ).should.be.equal( 'image/jpeg' )

    specify 'is image/gif given gif', ->
      MetaValue::_expandContentType( 'gif' ).should.be.equal( 'image/gif' )

    specify 'is image/png given png', ->
      MetaValue::_expandContentType( 'png' ).should.be.equal( 'image/png' )

  describe 'getContentType', ->

    specify 'is defined', ->
      should.exist( MetaValue::getContentType )
      MetaValue::getContentType.should.be.a( 'function' )

    specify 'is the value of contentType', ->
      metaValue = new MetaValue(
        contentType: 'application/joukou'
      ) 
      metaValue.getContentType().should.be.equal( 'application/joukou' )

