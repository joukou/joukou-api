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

module.exports =
[
  {
    name: 'MySQL Query'
    description: 'Obtain data from a MySQL database.'
    icon: 'database'
    subgraph: false
    image: "quay.io/joukou/joukou-circles-mysql"
    inports: [
      {
        id: 'query'
        name: 'query'
        type: 'string'
        description: 'The SELECT query to run against the MySQL database.'
        addressable: false
        required: true
      }
      {
        id: 'hostname'
        name: 'hostname'
        type: 'string'
        description: 'The hostname of the MySQL database.'
        addressable: false
        required: true
      }
      {
        id: 'username'
        name: 'username'
        type: 'string'
        description: 'The username for the MySQL database.'
        addressable: false
        required: true
      }
    ]
    outports: [
      {
        id: 'data'
        name: 'data'
        type: 'datum'
        description: 'The rows found by the MySQL query.'
        addressable: false
        required: true
      }
      {
        id: 'error'
        name: 'error'
        type: 'error'
        description: 'Any errors as a result of connecting to the database or executing the query'
        addressable: false
        required: false
      }
    ]
  }
  {
    name: 'Anonymizer'
    description: 'Anonymize data'
    icon: 'user'
    subgraph: false
    image: "quay.io/joukou/joukou-circles-anonymizer"
    inports: [
      {
        id: 'data'
        name: 'data'
        type: 'datum'
        description: 'The data to anonymize'
        addressable: false
        required: true
      }
    ]
    outports: [
      {
        id: 'data'
        name: 'data'
        type: 'datum'
        description: 'TThe anonymized data'
        addressable: false
        required: true
      }
      {
        id: 'err'
        name: 'err'
        type: 'error'
        description: 'Any errors'
        addressable: false
        required: true
      }
    ]
  }
  {
    name: 'Publish Search API'
    description: 'Publish a search API.'
    icon: 'search'
    subgraph: false
    image: "quay.io/joukou/joukou-circles-search"
    inports: [
      {
        id: 'data'
        name: 'data'
        type: 'datum'
        description: 'The data to index for searching'
        addressable: false
        required: true
      }
    ]
    outports: [
      {
        id: 'endpoint'
        name: 'endpoint'
        type: 'string'
        description: 'The URL of the search API endpoint'
        addressable: false
        required: true
      }
      {
        id: 'err'
        name: 'err'
        type: 'error'
        description: 'Any errors'
        addressable: false
        required: true
      }
    ]
  }
]