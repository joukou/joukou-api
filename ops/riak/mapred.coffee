###
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