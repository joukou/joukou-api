# using search as an input to map/reduce

###*
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

request(
  uri: 'http://localhost:8098/mapred'
  method: 'POST'
  json:
    inputs:
      module: 'yokozuna'
      function: 'mapred_search'
      arg: [ 'persona', 'agents.key:' + req.user.getKey() ]
    query: [
      {
        map:
          language: 'javascript'
          keep: false
          source: ( ( v, keyData, arg ) ->
            ejsLog( '/tmp/map_reduce.log', JSON.stringify( arg ) )
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
  res.send( 200, reply.body )
)

###
v:
  { bucket_type: 'persona',
  bucket: 'persona',
  key: '078b80e8-7f79-481c-bd7c-a61a5d0a5203',
  vclock: 'a85hYGBgzGDKBVIcypz/fgZPu6SewZTImMfKwBHLfZYvCwA=',
  values:
   [ { metadata:
        { 'X-Riak-VTag': '4IXaKVVnMY7gSWYRqSXm8U',
          'content-type': 'application/json',
          index: [],
          'X-Riak-Last-Modified': 'Tue, 10 Jun 2014 10:42:16 GMT' },
       data: '{"name":"Joukou Ltd","agents":[{"key":"718ccee0-514c-4370-976d-6798e05d25cd","role":"creator"}]}' } ] }

keyData: {}
arg: {}
###

###
simple search (not mapred)

request(
  uri: 'http://localhost:8098/search/persona?wt=json&q=agents.key:' + req.user.getKey()
, ( err, reply ) ->
  res.send( 200, reply.body )
)



faulty:


   {
            reduce:
              language: 'javascript'
              keep: true
              source: ( ( values, arg ) ->
                for value in values
                  value._links = {}
                  value._links['joukou:agent'] = []
                  for agent in agents
                    value._links['joukou:agent'].push(
                      href: "/agent/#{agent.key}"
                      role: agent.role
                    )
                values
              ).toString()
          }
###
