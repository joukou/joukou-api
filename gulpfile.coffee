###*
@author Isaac Johnston <isaac.johnston@joukou.co>
@copyright 2014 Joukou Ltd. All rights reserved.
###

gulp        = require( 'gulp' )
plugins     = require( 'gulp-load-plugins' )( lazy: false )

#
# Single-pass build related tasks
#

gulp.task( 'sloc', ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.sloc( ) )
)

gulp.task( 'clean', ->
  gulp.src( 'dist', read: false )
    .pipe( plugins.clean( force: true ) )
    .on( 'error', plugins.util.log )
)

gulp.task( 'coffeelint', [ 'sloc' ], ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.coffeelint( optFile: 'coffeelint.json' ) )
    .pipe( plugins.coffeelint.reporter() )
    .pipe( plugins.coffeelint.reporter( 'fail' ) )
)

gulp.task( 'coffee', [ 'clean' ], ->
  gulp.src( 'src/**/*.coffee' )
  .pipe( plugins.coffee( bare: true, sourceMap: true ) )
  .pipe( gulp.dest( 'dist' ) )
  .on( 'error', plugins.util.log )
)

gulp.task( 'build', [ 'sloc', 'coffeelint', 'coffee' ] )

gulp.task( 'mocha', ->
  gulp.src( 'test/**/*.coffee')
    .pipe( plugins.mocha(
      ui: 'bdd'
      reporter: 'spec'
      colors: true
      compilers: 'coffee:coffee-script/register'
    ) )
    .on( 'error', plugins.util.log )
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

gulp.task( 'coffeewatch', ->
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

gulp.task( 'mochawatch', ->
  gulp.src( [ 'dist/**/*.js', 'test/**/*.coffee' ], read: false )
    .pipe( plugins.watch( emit: 'all', ( files ) ->
      files
        .pipe( plugins.grepStream( '**/test/**/*.coffee' ) )
        .pipe( plugins.mocha(
          ui: 'bdd'
          reporter: 'spec'
          colors: true
          compilers: 'coffee:coffee-script/register'
        ) )
        .on( 'error', plugins.util.log )
    ) )
)

gulp.task( 'nodemon', ->
  plugins.nodemon(
    script: 'dist/server.js'
    ext: 'js'
    watch: [ 'dist', 'node_modules' ]
  )
  .on( 'restart', ->
      plugins.util.log( 'Restarted!' )
    )
)

gulp.task( 'develop', [ 'coffeewatch', 'mochawatch', 'nodemon' ] )
