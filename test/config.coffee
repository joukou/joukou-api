assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()

config = require( '../dist/config' )

describe 'config', ->

  specify 'loads the config.yml file', ->
    should.exist( config )
    config.mailer.transport.should.equal( 'PICKUP' )