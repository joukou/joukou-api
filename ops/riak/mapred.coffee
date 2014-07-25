request = require( 'request' )

request(
  uri: 'http://localhost:8098/mapred'
  method: 'POST'
  json:
    inputs: [ [ 'test', 'test' ] ]
    query: [
      {
        map:
          language: 'javascript'
          keep: false
          source: ( ( v, keyData, arg ) ->
            ejsLog( '/tmp/map_reduce.log', JSON.stringify( _.VERSION ) )
            return [ 1 ]
          ).toString()
      }
      {
        reduce:
          language: 'javascript'
          keep: true
          name: 'Riak.reduceSum'
      }
    ]
, ( err, reply ) ->
  console.log( err, reply.statusCode, reply.body )
)