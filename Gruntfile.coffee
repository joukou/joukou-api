"use strict"
###*
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright (c) 2009-2013 Joukou Ltd. All rights reserved.
###

matchdep = require( 'matchdep' )
path     = require( 'path' )

module.exports = ( grunt ) ->

  # Autoload all grunt tasks declared in the package.json file
  grunt.loadNpmTasks( gruntTask ) for gruntTask in matchdep.filterDev( 'grunt-*' )

  grunt.initConfig(
    pkg: grunt.file.readJSON( 'package.json' )

    clean:
      dist: [
        path.join( __dirname, 'dist' )
      ]

    coffee:
      compile:
        expand: true
        options:
          bare: true
          sourceMap: true
        cwd: path.join( __dirname, 'src' )
        src: [
          path.join( '**', '*.coffee' )
        ]
        dest: path.join( __dirname, 'dist' )
        ext: '.js'

    mochaTest:
      test:
        options:
          ui: 'bdd'
          reporter: 'spec'
          colors: true
          require: 'coffee-script'
        src: [
          path.join( __dirname, 'test', '**', '*.coffee' )
        ]

    watch:
      coffee:
        files: [
          path.join( __dirname, 'src', '**', '*.coffee' )
        ]
        tasks: [ 'coffee:compile' ]
      mochaTest:
        files: [
          path.join( __dirname, 'dist', '**', '*.js' )
          path.join( __dirname, 'test', '**', '*.coffee' )
        ]
        tasks: [ 'mochaTest:test' ]

    nodemon:
      dev:
        options:
          file: path.join( __dirname, 'dist', 'app.js' )
          nodeArgs: [ '--debug' ]
          ignoredFiles: [
            'Gruntfile.coffee'
            'LICENSE.md'
            'README.md'
            'circle.yml'
            'node_modules/**'
            'package.json'
            'src/**'
            'test/**'
          ]
          watchedExtensions: [ 'js' ]
          watchedFolders: [ path.join( __dirname, 'dist' ) ]
          legacyWatch: true
          delayTime: 1
          cwd: path.join( __dirname, 'dist' )
          env:
            JOUKOU_PORT: 3010

    concurrent:
      dev:
        tasks: [ 'nodemon', 'watch' ]
        options:
          logConcurrentOutput: true
  )

  grunt.registerTask( 'build', [
    'clean'
    'coffee:compile'
  ] )

  grunt.registerTask( 'test', [
    'build'
    'mochaTest:test'
  ] )

  grunt.registerTask( 'default', [ 'test' ] )
