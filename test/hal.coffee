assert            = require( 'assert' )
chai              = require( 'chai' )
should            = chai.should()
sinonChai         = require( 'sinon-chai' )
sinon             = require( 'sinon' )
chai.use( sinonChai ) 

_                 = require( 'lodash' )
http              = require( 'http' )
hal               = require( '../dist/hal' )
{ RestError, ForbiddenError } = require( 'restify' )

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

    specify 'is the application/hal+json representation of an object', ->
      req =
        path: ->
          '/test'
      res =
        setHeader: sinon.stub()
      body =
        person: 'Dr. Seuss'
        quote: 'Today you are you! That is truer than true! There is no one alive who is you-er than you!'

      middleware = hal.link()
      middleware( req, res, -> )

      hal.formatter( req, res, body ).should.equal( "{\"person\":\"Dr. Seuss\",\"quote\":\"Today you are you! That is truer than true! There is no one alive who is you-er than you!\",\"_links\":{\"self\":{\"href\":\"/test\"},\"curies\":[{\"name\":\"joukou\",\"templated\":true,\"href\":\"https://rels.joukou.com/{rel}\"}]}}" )
      res.setHeader.should.have.been.calledWith( 'Content-Length', 242 )

  describe '.link() middleware', -> 

    specify 'is defined', ->
      should.exist( hal.link )
      hal.link.should.be.a( 'function' )

    specify 'returns a middleware function', ->
      fn = hal.link()
      should.exist( fn )
      fn.should.be.a( 'function' )

    specify 'the returned middleware function adds a .link() method to the response object', ( done ) ->
      fn = hal.link()
      req = {}
      res = {}
      next = ->
        should.exist( res.link )
        res.link.should.be.a( 'function' )
        done()
      fn( req, res, next )

  describe '.parse( hal, schema )', ->

    specify 'parses an empty document', ->
      hal.parse( {}, {} ).should.deep.equal(
        embedded: {}
        links: {}
      )

    specify 'parses a joukou:circle link', ->
      hal.parse(
        _links:
          'joukou:circle': [
            {
              href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf/circle/fc097d4b-95a9-4c21-b7cd-5164253e05b0'
            }
          ]
      ,
        links:
          'joukou:circle':
            match: '/persona/:personaKey/circle/:circleKey'
      ).should.deep.equal(
        embedded: {}
        links:
          'joukou:circle': [
            {
              personaKey: '66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf'
              circleKey: 'fc097d4b-95a9-4c21-b7cd-5164253e05b0'
            }
          ]
      )

    specify 'normalizes a Link Object to an array of Link Objects', ->
      hal.parse(
        _links:
          'joukou:circle':
            href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf/circle/fc097d4b-95a9-4c21-b7cd-5164253e05b0'
      ,
        links:
          'joukou:circle':
            min: 1
            max: 1
            match: '/persona/:personaKey/circle/:circleKey'
      ).should.deep.equal(
        embedded: {}
        links:
          'joukou:circle': [
            {
              personaKey: '66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf'
              circleKey: 'fc097d4b-95a9-4c21-b7cd-5164253e05b0'
            }
          ]
      )

    specify 'parses a joukou:agent link with a name property', ->
      hal.parse(
        _links:
          'joukou:agent': [
            {
              href: '/agent/01b2b14c-1d1b-4112-85f0-1f4bc6c9961c'
              name: 'admin'
            }
          ]
      ,
        links:
          'joukou:agent':
            match: '/agent/:key'
            name:
              required: true
              type: 'enum'
              values: [ 'admin' ]
      ).should.deep.equal(
        embedded: {}
        links:
          'joukou:agent': [
            {
              key: '01b2b14c-1d1b-4112-85f0-1f4bc6c9961c'
              name: 'admin'
            }
          ]
      )

    specify 'throws ForbiddenError if _links is not an object', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links: true
        ,
          {}
        )
      )
      fn.should.throw( ForbiddenError, /_links must be an object/ )

    specify 'throws ForbiddenError if the link relation type is not defined in the schema', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:bogus': [
              {
                href: '/bogus/01b2b14c-1d1b-4112-85f0-1f4bc6c9961c'
              }
            ]
        ,
          links:
            'joukou:agent':
              match: '/bogus/:key'
        )
      )
      fn.should.throw( ForbiddenError, /the link relation type joukou:bogus is not supported for this resource/ )

    specify 'throws ForbiddenError if a link relation type is not defined and the schema has a minimum defined', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links: {}
        ,
          links:
            'joukou:circle':
              min: 1
        )
      )
      fn.should.throw( ForbiddenError, /the link relation type joukou:circle does not support less than 1 Link Objects for this resource/ )

    specify 'throws ForbiddenError if a link relation type has less Link Objects than the minimum defined in the schema', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:circle': []
        ,
          links:
            'joukou:circle':
              min: 1
        )
      )
      fn.should.throw( ForbiddenError, /the link relation type joukou:circle does not support less than 1 Link Objects for this resource/ )

    specify 'throws ForbiddenError if a link relation type has more Link Objects than the maximum defined in the schema', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:circle': [
              {
                href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf/circle/fc097d4b-95a9-4c21-b7cd-5164253e05b0'
              }
              {
                href: '/persona/87191f78-e4c0-438c-80d4-2fff7301ff52/circle/ebfa28dc-e262-4f8d-a2b2-03874e5950d3'
              }
            ]
        ,
          links:
            'joukou:circle':
              max: 1
        )
      )
      fn.should.throw( ForbiddenError, /the link relation type joukou:circle does not support more than 1 Link Objects for this resource/ )

    specify 'throws ForbiddenError if a Link Object does not have a href property', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:circle': [
              {
                href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf/circle/fc097d4b-95a9-4c21-b7cd-5164253e05b0'
              }
              {
                name: 'bogus'
              }
            ]
        ,
          links:
            'joukou:circle':
              match: '/persona/:personaKey/circle/:circleKey'
        )
      )
      fn.should.throw( ForbiddenError, /Link Objects must have a href property/ )

    specify 'throws ForbiddenError if a Link Object\'s href property does not match the schema', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:circle': [
              {
                href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf'
              }
            ]
        ,
          links:
            'joukou:circle':
              match: '/persona/:personaKey/circle/:circleKey'
        )
      )
      fn.should.throw( ForbiddenError, /failed to extract keys from href property/ )

    specify 'throws ForbiddenError if a Link Object is missing a required name property', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:circle': [
              {
                href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf/circle/fc097d4b-95a9-4c21-b7cd-5164253e05b0'
              }
            ]
        ,
          links:
            'joukou:circle':
              match: '/persona/:personaKey/circle/:circleKey'
              name:
                required: true
        )
      )
      fn.should.throw( ForbiddenError, /the link relation type joukou:circle requires a name property/ )     
      
    specify 'throws ForbiddenError if a Link Object\'s name property does not match an enum type', ->
      fn = _.wrap( hal.parse, ( parse ) ->
        parse(
          _links:
            'joukou:circle': [
              {
                href: '/persona/66d223ce-bb6c-47fb-bc4d-c5bf4f5d2abf/circle/fc097d4b-95a9-4c21-b7cd-5164253e05b0'
                name: 'bogus'
              }
            ]
        ,
          links:
            'joukou:circle':
              match: '/persona/:personaKey/circle/:circleKey'
              name:
                required: true
                type: 'enum'
                values: [ 'an_enum' ]
        )
      )
      fn.should.throw( ForbiddenError, /the link relation type joukou:circle requires a name property value that is one of: an_enum/ ) 


