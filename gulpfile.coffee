###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright 2014 Joukou Ltd. All rights reserved.
###

gulp        = require( 'gulp' )
plugins     = require( 'gulp-load-plugins' )( lazy: false )
joukou      = require( 'joukou-gulp' )( gulp, plugins )

apidoc      = require( 'apidoc' )
lazypipe    = require( 'lazypipe' )
path        = require( 'path' )

###*
@namespace
###
paths =
  src:
    dir: 'src'
    coffee: path.join( 'src', '**', '*.coffee' )
  dist:
    dir: 'dist'
    js: path.join( 'dist', '**', '*.js' )
    jsdoc: path.join( 'dist', 'jsdoc' )
    apidoc: path.join( 'dist', 'apidoc' )
  test:
    coffee: path.join( 'test', '**', '*.coffee' )
    coverage: './coverage'

###*
@namespace
###
lazypipes =
  mocha: lazypipe().pipe( plugins.mocha,
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
    gulp.src( paths.dist.dir, read: false )
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
      .pipe( gulp.dest( paths.dist.dir ) )
      .on( 'error', plugins.util.log )

  jsdoc: ->
    gulp.src( paths.dist.js )
      .pipe( plugins.jsdoc.parser(
        description: require( './package.json' ).description
        version: require( './package.json' ).version
        licenses: [ require( './package.json').license ]
        plugins: [ 'plugins/markdown' ]
      ) )
      .pipe( plugins.jsdoc.generator( paths.dist.jsdoc,
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

  apidoc: ( done ) ->
    count = apidoc(
      src: paths.src.dir
      dest: paths.dist.apidoc
      debug: false
      includeFilters: [ '.*\\.coffee$' ]
      template: path.join( __dirname, 'apidoc_template' )
    )
    plugins.util.log( 'apidoc:' + count )
    done()

  deployPackageZip: ->
    gulp.src( '**/*' )
      .pipe( plugins.grepStream( '**/dist/apidoc/**/*', invertMatch: true ) )
      .pipe( plugins.zip( joukou.getPackageZipFilename() ) )
      .pipe( gulp.dest( joukou.getArtifactsDir() ) )

  deployDocZip: ->
    gulp.src( 'dist/apidoc/**/*' )
      .pipe( plugins.zip( joukou.getDocZipFilename() ) )
      .pipe( gulp.dest( joukou.getArtifactsDir() ) )

  test: ( done ) ->
    gulp.src( paths.dist.js )
    .pipe( plugins.istanbul() )
    .on( 'finish', ->
      gulp.src( [ paths.test.coffee ], read: false )
      .pipe( lazypipes.mocha( ) )
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
gulp.task( 'apidoc:build', [ 'coffee:build' ], tasks.apidoc )
gulp.task( 'build', [ 'sloc', 'coffeelint', 'jsdoc:build', 'apidoc:build' ] )

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

# Create package ZIP file
gulp.task( 'zip:deploy', tasks.deployPackageZip )

# Upload package ZIP file
gulp.task( 'upload-akl1:deploy', [ 'zip:deploy' ], joukou.doPackageDeploymentUpload( host: 'akl1.joukou.com' ) )
gulp.task( 'upload-akl2:deploy', [ 'zip:deploy' ], joukou.doPackageDeploymentUpload( host: 'akl2.joukou.com' ) )
gulp.task( 'upload-akl3:deploy', [ 'zip:deploy' ], joukou.doPackageDeploymentUpload( host: 'akl3.joukou.com' ) )
gulp.task( 'upload:deploy', [ 'upload-akl1:deploy', 'upload-akl2:deploy', 'upload-akl3:deploy' ] )

gulp.task( 'commands-akl1:deploy', [ 'upload:deploy' ], joukou.doPackageDeploymentCommands( host: 'akl1.joukou.com' ) )
gulp.task( 'commands-akl2:deploy', [ 'upload:deploy' ], joukou.doPackageDeploymentCommands( host: 'akl2.joukou.com' ) )
gulp.task( 'commands-akl3:deploy', [ 'upload:deploy' ], joukou.doPackageDeploymentCommands( host: 'akl3.joukou.com' ) )
gulp.task( 'commands:deploy', [ 'commands-akl1:deploy', 'commands-akl2:deploy', 'commands-akl3:deploy' ] )
gulp.task( 'notification:deploy', [ 'commands:deploy' ], joukou.doPackageDeploymentNotification() )


# Create documentation ZIP file
gulp.task( 'zip:deploy-apidoc', [ 'notification:deploy'], tasks.deployDocZip )

# Upload documentation ZIP file
gulp.task( 'upload-akl1:deploy-apidoc', [ 'zip:deploy-apidoc' ], joukou.doDocDeploymentUpload( host: 'akl1.joukou.com' ) )
gulp.task( 'upload-akl2:deploy-apidoc', [ 'zip:deploy-apidoc' ], joukou.doDocDeploymentUpload( host: 'akl2.joukou.com' ) )
gulp.task( 'upload-akl3:deploy-apidoc', [ 'zip:deploy-apidoc' ], joukou.doDocDeploymentUpload( host: 'akl3.joukou.com' ) )
gulp.task( 'upload:deploy-apidoc', [ 'upload-akl1:deploy-apidoc', 'upload-akl2:deploy-apidoc', 'upload-akl3:deploy-apidoc' ] )

gulp.task( 'commands-akl1:deploy-apidoc', [ 'upload:deploy-apidoc' ], joukou.doDocDeploymentCommands( host: 'akl1.joukou.com' ) )
gulp.task( 'commands-akl2:deploy-apidoc', [ 'upload:deploy-apidoc' ], joukou.doDocDeploymentCommands( host: 'akl2.joukou.com' ) )
gulp.task( 'commands-akl3:deploy-apidoc', [ 'upload:deploy-apidoc' ], joukou.doDocDeploymentCommands( host: 'akl3.joukou.com' ) )
gulp.task( 'commands:deploy-apidoc', [ 'commands-akl1:deploy-apidoc', 'commands-akl2:deploy-apidoc', 'commands-akl3:deploy-apidoc' ] )
gulp.task( 'notification:deploy-apidoc', [ 'commands:deploy-apidoc' ], joukou.doDocDeploymentNotification() )


gulp.task( 'deploy', [ 'notification:deploy-apidoc' ] )

#
# Develop tasks.
#

gulp.task( 'coffee:develop', tasks.coffee )

gulp.task( 'test:develop', [ 'build' ], ->
  gulp.src( [ 'dist/**/*.js', 'test/**/*.coffee' ], read: false )
    .pipe( plugins.watch( emit: 'all', ( files ) ->
      files
        .pipe( plugins.grepStream( '**/test/**/*.coffee' ) )
        .pipe( lazypipes.mocha() )
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

gulp.task( 'foo', ( done ) ->

  console.log( joukou.getName() )

)