###*
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright 2014 Joukou Ltd. All rights reserved.
###

gulp        = require( 'gulp' )
lazypipe    = require( 'lazypipe' )
plugins     = require( 'gulp-load-plugins' )( lazy: false )
fs          = require( 'fs' )

isCI = process.env.CI is 'true'

mocha = lazypipe().pipe( plugins.spawnMocha,
  ui: 'bdd'
  reporter: 'spec'
  compilers: 'coffee:coffee-script/register'
)

#
# Single-pass build related tasks
#

gulp.task( 'sloc', ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.sloc( ) )
)

gulp.task( 'clean', ->
  stream = gulp.src( 'dist', read: false )
    .pipe( plugins.clean( force: true ) )
    .on( 'error', plugins.util.log )
  unless isCI
    stream.on( 'error', plugins.notify.onError(
      title: 'joukou-api: gulp clean'
      message: '<%= error.message %>'
    ) )
  stream
)

gulp.task( 'coffeelint', [ 'sloc' ], ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.coffeelint( optFile: 'coffeelint.json' ) )
    .pipe( plugins.coffeelint.reporter() )
    .pipe( plugins.coffeelint.reporter( 'fail' ) )
)

gulp.task( 'coffee', [ 'clean' ], ->
  stream = gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.coffee( bare: true, sourceMap: true ) )
    .pipe( gulp.dest( 'dist' ) )
    .on( 'error', plugins.util.log )
  unless isCI
    stream.pipe( plugins.notify(
        title: 'joukou-api: gulp coffee'
        message: 'CoffeeScript compiled successfully.'
        onLast: true
      ) )
    .on( 'error', plugins.notify.onError(
        title: 'joukou-api: gulp coffee'
        message: '<%= error.message %>'
      ))
  stream
)

gulp.task( 'jsdoc', [ 'coffee' ], ->
  gulp.src( 'dist/**/*.js' )
    .pipe( plugins.jsdoc.parser(
      description: 'Description here'
      version: 'verison here'
      licenses: [ 'license here' ]
      plugins: [ 'plugins/markdown' ]
    ) )
    .pipe( plugins.jsdoc.generator( './dist/docs',
      path: 'ink-docstrap'
      systemName: 'Joukou Platform API'
      footer: 'What could you do with data ?'
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
)

gulp.task( 'build', [ 'sloc', 'coffeelint', 'coffee', 'jsdoc' ] )

gulp.task( 'cover', [ 'build' ], ->
  gulp.src( 'dist/**/*.js' )
    .pipe( plugins.istanbul() )
    .on( 'error', plugins.util.log )
)


gulp.task( 'test', [ 'cover' ], ->
  stream = gulp.src( [ 'test/**/*.coffee' ], read: false )
    .pipe( mocha() )
    .pipe( plugins.istanbul.writeReports( './coverage' ) )
    .on( 'error', ( err ) ->
      process.exit( 1 )
    )
  unless isCI
    stream.pipe( plugins.notify(
      title: 'joukou-api: gulp test'
      message: 'Tests complete.'
      onLast: true
    ) )
  stream
)

gulp.task( 'ci', [ 'test' ], ->
  gulp.src( 'coverage/lcov.info' )
    .pipe( plugins.coveralls() )
)

#
# Release related tasks
#

gulp.task( 'contribs', ->
  gulp.src( 'README.md' )
    .pipe( plugins.contribs( '## Contributors', '## License' ) )
    .pipe( gulp.dest( './' ) )
)

#
# Develop-mode continuous compilation and auto server restart related tasks
#

gulp.task( 'coffeewatch', [ 'build' ], ->
  changes = gulp.src( 'src/**/*.coffee', read: false )
    .pipe( plugins.watch( ) )

  changes
    .pipe( plugins.changed( 'dist' ) )
    .pipe( plugins.coffee( bare: true, sourceMap: true ) )
    .pipe( gulp.dest( 'dist' ) )
    .on( 'error', plugins.util.log )

  changes
    .pipe( plugins.coffeelint( optFile: 'coffeelint.json' ) )
    .pipe( plugins.coffeelint.reporter( ) )
)

gulp.task( 'mochawatch', [ 'build' ], ->
  gulp.src( [ 'dist/**/*.js', 'test/**/*.coffee' ], read: false )
    .pipe( plugins.watch( emit: 'all', ( files ) ->
      stream = files
        .pipe( plugins.grepStream( '**/test/**/*.coffee' ) )
        .pipe( mocha() )
        .on( 'error', plugins.util.log )
      unless isCI
        stream.on( 'error', plugins.notify.onError(
          title: 'joukou-api: gulp mochawatch'
          message: '<%= error.message %>'
        ))
      stream
    ) )
)

gulp.task( 'nodemon', [ 'build' ], ->
  plugins.nodemon(
    script: 'dist/server.js'
    env:
      JOUKOU_PORT: 3010
    ext: 'js'
    watch: [ 'dist', 'node_modules' ]
  )
  .on( 'restart', ->
      plugins.util.log( 'Restarted!' )
    )
)

gulp.task( 'develop', [ 'coffeewatch', 'mochawatch', 'nodemon' ] )
