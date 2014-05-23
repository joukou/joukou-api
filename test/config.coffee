assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()

fs     = require( 'fs' )
path   = require( 'path' )
configFile = path.join( __dirname, '..', 'config.yml' )

describe 'config', ->

  before ( done ) ->
    fs.writeFile( configFile, 'test: "is good"', encoding: 'utf8', done )

  # broken because modules are singletons
  xspecify 'loads the config.yml file', ->
    config = require( '../dist/config' )
    should.exist( config )
    config.test.should.equal( "is good" )

  after ( done ) ->
    fs.unlink( configFile, done )