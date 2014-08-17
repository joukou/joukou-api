###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

assert        = require( 'assert' )
chai          = require( 'chai' )
should        = chai.should()
chai.use( require( 'chai-http' ) )

server        = require( '../../dist/server' )

xdescribe 'contact/routes', ->

  describe 'POST /contact', ->

    specify 'creates an email message based on a message-oriented contact request', ( done ) ->
      chai.request( server )
        .post( '/contact' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            name: 'Isaac Johnston'
            email: 'isaac.johnston@joukou.com'
            message: 'This is a test.'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )

    specify 'creates an email message based on a signup-oriented contact request', ( done ) ->
      chai.request( server )
        .post( '/contact' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            name: 'Isaac Johnston'
            email: 'isaac.johnston@joukou.com'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )