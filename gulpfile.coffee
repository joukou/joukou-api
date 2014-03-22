###*
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright 2014 Joukou Ltd. All rights reserved.
###

gulp        = require( 'gulp' )
gutil       = require( 'gulp-util' )
changed     = require( 'gulp-changed' )
coffee      = require( 'gulp-coffee' )
coffeelint  = require( 'gulp-coffeelint' )
clean       = require( 'gulp-clean' )
grep        = require( 'gulp-grep-stream' )
mocha       = require( 'gulp-mocha' )
nodemon     = require( 'gulp-nodemon' )
plumber     = require( 'gulp-plumber' )
sloc        = require( 'gulp-sloc' )
watch       = require( 'gulp-watch' )

#
# Single-pass build related tasks
#

gulp.task( 'sloc', ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( sloc( ) )
)

gulp.task( 'clean', ->
  gulp.src( 'dist', read: false )
    .pipe( clean( force: true ) )
    .on( 'error', gutil.log )
)

gulp.task( 'coffeelint', ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( coffeelint( optFile: 'coffeelint.json' ) )
    .pipe( coffeelint.reporter() )
    .pipe( coffeelint.reporter( 'fail' ) )
)

gulp.task( 'coffee', [ 'clean' ], ->
  gulp.src( 'src/**/*.coffee' )
  .pipe( coffee( bare: true, sourceMap: true ) )
  .pipe( gulp.dest( 'dist' ) )
  .on( 'error', gutil.log )
)

gulp.task( 'build', [ 'sloc', 'coffeelint', 'coffee' ] )

gulp.task( 'mocha', ->
  gulp.src( 'test/**/*.coffee')
    .pipe( mocha(
      ui: 'bdd'
      reporter: 'spec'
      colors: true
      compilers: 'coffee:coffee-script/register'
    ) )
    .on( 'error', gutil.log )
)

#
# Develop-mode continuous compilation and auto server restart related tasks
#

gulp.task( 'coffeewatch', ->
  changes = gulp.src( 'src/**/*.coffee', read: false )
    .pipe( watch( ) )

  changes
    .pipe( changed( 'dist' ) )
    .pipe( coffee( bare: true, sourceMap: true ) )
    .pipe( gulp.dest( 'dist' ) )
    .on( 'error', gutil.log )

  changes
    .pipe( coffeelint( optFile: 'coffeelint.json' ) )
    .pipe( coffeelint.reporter( ) )
)

gulp.task( 'mochawatch', ->
  gulp.src( [ 'dist/**/*.js', 'test/**/*.coffee' ], read: false )
    .pipe( watch( emit: 'all', ( files ) ->
      files
        .pipe( grep( '**/test/**/*.coffee' ) )
        .pipe( mocha(
          ui: 'bdd'
          reporter: 'spec'
          colors: true
          compilers: 'coffee:coffee-script/register'
        ) )
        .on( 'error', gutil.log )
    ) )
)

gulp.task( 'nodemon', ->
  nodemon(
    script: 'dist/server.js'
    ext: 'js'
    watch: [ 'dist', 'node_modules' ]
  )
  .on( 'restart', ->
      console.log( 'Restarted!' )
    )
)

gulp.task( 'develop', [ 'coffeewatch', 'mochawatch', 'nodemon' ] )