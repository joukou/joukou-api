assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use( chaiAsPromised )
should            = chai.should()

riakpbc           = require( 'riakpbc' ).createClient(
                      host: 'localhost'
                      port: 8087
                    )
riak              = require( '../../dist/riak/Client' )
MetaValue         = require( '../../dist/riak/MetaValue' )
NotFoundError     = require( '../../dist/riak/NotFoundError' )

describe 'riak/Client', ->

  specify 'is defined', ->
    riak.should.exist

  describe 'get', ->

    before ( done ) ->
      riakpbc.put(
        bucket: 'test'
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
      should.exist( riak.get )
      riak.get.should.be.a( 'function' )

    specify 'is eventually rejected with a NotFoundError if the bucket/key location does not exist', ->
      riak.get( bucket: 'nonexistent', key: 'nonexistent' )
        .should.eventually.be.rejectedWith( NotFoundError )

    specify 'is eventually resolved with a MetaValue if the bucket/key location does exist', ->
      riak.get( bucket: 'test', key: 'bob_marley' ).then( ( metaValue ) ->
        should.exist( metaValue )
        metaValue.should.be.an.instanceof( MetaValue )
        metaValue.getValue().should.eql(
          future: 'In this bright future you can\'t forget your past.'
          free: 'None but ourselves can free our minds.'
        )
      )

    after ( done ) ->
      riakpbc.del( bucket: 'test', key: 'bob_marley', ( err, reply ) ->
        done()
      )

  describe 'put', ->

    specify 'is defined', ->
      should.exist( riak.put )
      riak.put.should.be.a( 'function' )

    specify 'is eventually resolved with a TODO given a bucket, key and value', ->
      riak.put(
        bucket: 'test'
        key: 'bruce_lee'
        value:
          learning: 'A wise man can learn more from a foolish question than a fool can learn from a wise answer.'
          power: 'Knowledge will give you power, but character respect.'
      ).should.be.fulfilled

    after ( done ) ->
      riakpbc.del( bucket: 'test', key: 'bruce_lee', ( err, reply ) ->
        done()
      )
