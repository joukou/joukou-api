###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

assert      = require( 'assert' )
chai        = require( 'chai' )
should      = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel  = require( '../../dist/agent/Model' )
server      = require( '../../dist/server' )
riakpbc     = require( '../../dist/riak/pbc' )

###
Attempt to monkey-patch application/hal+json parsing. Appears to cause empty
response body, futher investigation needed. For now server is configured to
send application/json responses.

superagent  = require( 'chai-http/node_modules/superagent' )
superagent.parse[ 'application/hal+json' ] = ( res, done ) ->
  res.text = ''
  res.setEncoding( 'utf8' )
  res.on( 'data', ( chunk ) -> res.text += chunk )
  res.on( 'end', ->
    try
      done( null, JSON.parse( res.text ) )
    catch err
      done( err )
  )
###

describe 'agent/routes', ->

  describe 'POST /agent', ->

    specify 'creates a new agent given valid data', ( done ) ->
      chai.request( server )
        .post( '/agent' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            email: 'test+agent+routes+create@joukou.com'
            name: 'test/agent/routes/create'
            password: 'password'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          res.headers.location.should.match( /^\/agent\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )
          key = res.headers.location.match( /^\/agent\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]
          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer( "test+agent+routes+create@joukou.com:password" ).toString( 'base64' )}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )

              riakpbc.del(
                bucket: 'agent'
                key: key
              , ( err ,reply ) ->
                done( err )
              )
            )
        )


  describe 'GET /agent/:key', ->
  
    key = null

    before ( done ) ->
      AgentModel.create(
        email: 'test+agent+routes+retrieve@joukou.com'
        name: 'test/agent/routes/retrieve'
        password: 'password'
      ).then( ( agent ) ->
        agent.save().then( ->
          key = agent.getKey()
          done()
        ).fail( ( err ) ->
          done( err )
        )
      ).fail( ( err ) ->
        done( err )
      )

    specify 'retrieves the agent identified by the given key', ( done ) ->
      chai.request( server )
        .get( "/agent/#{key}" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer( 'test+agent+routes+retrieve@joukou.com:password' ).toString( 'base64' )}")
        )
        .res( ( res ) ->
          res.should.have.status( 200 )
          res.body.should.deep.equal(
            email: 'test+agent+routes+retrieve@joukou.com'
            name: 'test/agent/routes/retrieve'
            _links:
              self: [
                {
                  href: "/agent/#{key}"
                }
              ]
              curies: [
                name: 'joukou'
                templated: true
                href: 'https://rels.joukou.com/{rel}'
              ]
          )
          done()
        )

    after ( done ) ->
      riakpbc.del(
        type: 'agent'
        bucket: 'agent'
        key: key
      , ( err, reply ) ->
        done( err )
      )

  describe 'POST /authenticate', ->

    key = null

    before ( done ) ->
      AgentModel.create(
        email: 'test+agent+routes+authenticate@joukou.com'
        name: 'test/agent/routes/authenticate'
        password: 'password'
      ).then( ( agent ) ->
        agent.save().then( ->
          key = agent.getKey()
          done()
        ).fail( ( err ) ->
          done( err )
        )
      ).fail( ( err ) ->
        done( err )
      )

    specify 'responds with a JSON Web Token if the provided Authorization header is authenticated', ( done ) ->
      chai.request( server )
        .post( '/agent/authenticate' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer( 'test+agent+routes+authenticate@joukou.com:password' ).toString( 'base64' )}")
        )
        .res( ( res ) ->
          res.should.have.status( 200 )
          should.exist( res.body.token )
          res.body.token.should.be.a( 'string' )
          res.body._links.should.deep.equal(
            self: [
              href: '/agent/authenticate'
            ]
            curies: [
              name: 'joukou'
              templated: true
              href: 'https://rels.joukou.com/{rel}'
            ]
          )
          done()
        )

    specify 'responds with 401 Unauthorized status code if the provided Authorization header is not authenticated', ( done ) ->
      chai.request( server )
        .post( '/agent/authenticate' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer( 'test+agent+routes+authenticate@joukou.com:bogus' ).toString( 'base64' )}")
        )
        .res( ( res ) ->
          res.should.have.status( 401 )
          res.body.should.be.empty
          done()
        )

    after ( done ) ->
      riakpbc.del(
        type: 'agent'
        bucket: 'agent'
        key: key
      , ( err, reply ) ->
        done( err )
      )