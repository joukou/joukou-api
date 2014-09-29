Joukou RESTful API
==================
[![Build Status](https://circleci.com/gh/joukou/joukou-api/tree/develop.png?circle-token=2eaaef867852e13944b9667a6234821ec1325d4d)](https://circleci.com/gh/joukou/joukou-api/tree/develop) [![Docker Repository on Quay.io](https://quay.io/repository/joukou/api/status?token=92369985-9a0a-4816-ba57-514f75b77cfa "Docker Repository on Quay.io")](https://quay.io/repository/joukou/api) [![Coverage Status](https://coveralls.io/repos/joukou/joukou-api/badge.png?branch=develop)](https://coveralls.io/r/joukou/joukou-api?branch=develop) [![Apache 2.0](http://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](#license) [![Stories in Ready](https://badge.waffle.io/joukou/joukou-api.png?label=ready&title=Ready)](http://waffle.io/joukou/joukou-api) [![IRC](http://img.shields.io/badge/IRC-%23joukou-blue.svg)](http://webchat.freenode.net/?channels=joukou)

![](http://media.giphy.com/media/tdbOA2fGn3q7e/giphy.gif)

## Getting Started

Install supporting tools:

1. `$ npm -g install http-console gulp`

For the project itself:

1. `$ cd joukou-api`
1. `$ npm install`
1. `$ gulp build` for a single build or `$ gulp develop` for watch mode. Single
builds are currently more stable as watch mode continues to be refined.
1. `$ node dist/server.js`

JavaScript documentation is generated in `dist/docs`.

## License

Copyright &copy; 2014 Joukou Ltd.

Joukou RESTful API is under the Apache 2.0 license. See the
[LICENSE](LICENSE) file for details.