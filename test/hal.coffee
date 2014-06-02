assert            = require( 'assert' )
chai              = require( 'chai' )
should            = chai.should()
sinonChai         = require( 'sinon-chai' )
sinon             = require( 'sinon' )
chai.use( sinonChai ) 

http              = require( 'http' )
hal               = require( '../dist/hal' )
{ RestError } = require( 'restify' )

describe 'joukou-api/hal', ->

  describe '.formatter( req, res, body )', ->

    specify 'is defined', ->
      should.exist( hal.formatter )
      hal.formatter.should.be.a( 'function' )

    specify 'is the base64 encoded representation of a Buffer', ->
      req = {}
      res =
        setHeader: sinon.stub()
      body = new Buffer( 'The roots of education are bitter, but the fruit is sweet.' )
      hal.formatter( req, res, body ).should.equal( 'VGhlIHJvb3RzIG9mIGVkdWNhdGlvbiBhcmUgYml0dGVyLCBidXQgdGhlIGZydWl0IGlzIHN3ZWV0Lg==' )
      res.setHeader.should.have.been.calledWith( 'Content-Length', 80 )

    specify 'is the application/vnd.error+json representation of an Error', ->
      req = {}
      res =
        setHeader: sinon.stub()
      body = new RestError(
        restCode: 'TeapotError'
        statusCode: 418
        message: 'I\'m a teapot'
      )
      hal.formatter( req, res, body ).should.equal( '{"logref":"TeapotError","message":"I\'m a teapot"}' )
      res.statusCode.should.equal( 418 )
      res.setHeader.should.have.been.calledWith( 'Content-Length', 49 )
      res.setHeader.should.have.been.calledWith( 'Content-Type', 'application/vnd.error+json' )

  describe '.link() middleware', -> 

    specify 'is defined', ->
      should.exist( hal.link )
      hal.link.should.be.a( 'function' )

    specify 'returns a middleware function', ->
      fn = hal.link()
      should.exist( fn )
      fn.should.be.a( 'function' )

    xspecify 'the returned middleware function adds a ::link method to the response object', ( done ) ->
      fn = hal.link()
      req = {} #new http.ClientRequest()
      res = {} #new http.ServerResponse()
      next = ->
        should.exist( res::link )
        res::link.should.be.a( 'function' )
        done()
      fn( req, res, next )

    #describe 'res::link( href, rel, props )', ->

