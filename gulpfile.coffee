###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright 2014 Joukou Ltd. All rights reserved.
###

gulp        = require( 'gulp' )
lazypipe    = require( 'lazypipe' )
plugins     = require( 'gulp-load-plugins' )( lazy: false )
fs          = require( 'fs' )
path        = require( 'path' )

###*
@namespace
###
paths =
  src:
    coffee: path.join( 'src', '**', '*.coffee' )
  dist:
    dest: 'dist'
    js: path.join( 'dist', '**', '*.js' )
    docs: path.join( 'dist', 'docs' )
  test:
    coffee: path.join( 'test', '**', '*.coffee' )
    coverage: './coverage'

###*
@namespace
###
utils =
  isCI: ->
    process.env.CI is 'true'

###*
@namespace
###
lazypipes =
  mocha = lazypipe().pipe( plugins.mocha,
    ui: 'bdd'
    reporter: 'spec'
    compilers: 'coffee:coffee-script/register'
  )

###*
Task functions are defined independently of dependencies to enable re-use in
different lifecycles; e.g. single pass build vs watch based develop mode.
@namespace
###
tasks =
  sloc: ->
    gulp.src( paths.src.coffee )
      .pipe( plugins.sloc() )

  clean: ->
    gulp.src( paths.dist.dest, read: false )
      .pipe( plugins.clean( force: true ) )
      .on( 'error', plugins.util.log )

  coffeelint: ->
    gulp.src( paths.src.coffee )
      .pipe( plugins.coffeelint( optFile: 'coffeelint.json' ) )
      .pipe( plugins.coffeelint.reporter() )
      .pipe( plugins.coffeelint.reporter( 'fail' ) )

  coffee: ->
    gulp.src( paths.src.coffee )
      .pipe( plugins.coffee( bare: true, sourceMap: true ) )
      .pipe( gulp.dest( paths.dist.dest ) )
      .on( 'error', plugins.util.log )

  jsdoc: ->
    gulp.src( paths.dist.js )
      .pipe( plugins.jsdoc.parser(
        description: require( './package.json' ).description
        version: require( './package.json' ).version
        licenses: [ require( './package.json').license ]
        plugins: [ 'plugins/markdown' ]
      ) )
      .pipe( plugins.jsdoc.generator( paths.dist.docs,
        path: 'ink-docstrap'
        systemName: 'Joukou Platform API.'
        footer: 'A simple and intuitive way to web enable and monetize your data.'
        copyright: 'Joukou Ltd. All rights reserved.'
        navType: 'vertical'
        theme: 'cerulean'
        linenums: true
        collapseSymbols: false
        inverseNav: false
      ,
        private: false
        monospaceLinks: false
        cleverLinks: false
        outputSourceFiles: false
      ) )

  test: ( done ) ->
    gulp.src( paths.dist.js )
    .pipe( plugins.istanbul() )
    .on( 'finish', ->
      gulp.src( [ paths.test.coffee ], read: false )
      .pipe( mocha( ) )
      .pipe( plugins.istanbul.writeReports( paths.test.coverage ) )
      .on( 'end', done )
    )
    return

  coveralls: ->
    gulp.src( 'coverage/lcov.info' )
      .pipe( plugins.coveralls() )
      .on( 'end', ->
        process.exit(0)
      )

#
# General tasks.
#

gulp.task( 'sloc', tasks.sloc )
gulp.task( 'coffeelint', tasks.coffeelint )

#
# Build tasks.
#

gulp.task( 'clean:build', tasks.clean )
gulp.task( 'coffee:build', [ 'clean:build' ], tasks.coffee )
gulp.task( 'jsdoc:build', [ 'coffee:build' ], tasks.jsdoc )
gulp.task( 'build', [ 'sloc', 'coffeelint', 'jsdoc:build' ] )

gulp.task( 'test:build', [ 'build' ], tasks.test )
gulp.task( 'test', [ 'test:build' ], ->
  # test is intended to be an interactively run build; i.e. not CI. Force a
  # clean exit due to issues with gulp-mocha not cleaning up gracefully.
  process.exit(0)
)

#
# Continuous-integration tasks.
#

gulp.task( 'ci', [ 'test:build' ], tasks.coveralls )

#
# Develop tasks.
#

gulp.task( 'coffee:develop', tasks.coffee )

gulp.task( 'test:develop', [ 'build' ], ->
  gulp.src( [ 'dist/**/*.js', 'test/**/*.coffee' ], read: false )
    .pipe( plugins.watch( emit: 'all', ( files ) ->
      files
        .pipe( plugins.grepStream( '**/test/**/*.coffee' ) )
        .pipe( mocha() )
        .on( 'error', plugins.util.log )
    ) )
)

gulp.task( 'nodemon:develop', [ 'build' ], ->
  plugins.nodemon(
    script: 'dist/server.js'
    env:
      JOUKOU_PORT: 3010
    ext: 'js'
    watch: [ 'dist', 'node_modules' ]
  )
  .on( 'restart', ->
    plugins.util.log( 'Server Restarted!' )
  )
)

gulp.task( 'develop', [ 'build', 'test:develop', 'nodemon:develop' ], ->
  gulp.watch( paths.src.coffee, [ 'sloc', 'coffeelint', 'coffee:develop' ] )
)