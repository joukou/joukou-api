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
nodemon     = require( 'gulp-nodemon' )

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

gulp.task( 'build', [ 'coffeelint', 'coffee' ] )