###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright 2014 Joukou Ltd. All rights reserved.
###

gulp        = require( 'gulp' )
lazypipe    = require( 'lazypipe' )
plugins     = require( 'gulp-load-plugins' )( lazy: false )
fs          = require( 'fs' )
path        = require( 'path' )
apidoc      = require( 'apidoc' )
request     = require( 'request' )

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
utils =
  isCI: ->
    process.env.CI is 'true'

  getDeploymentEnvironment: ->
    switch process.env.CIRCLE_BRANCH
      when 'master'
        'production'
      when 'develop'
        'staging'
      else
        ''

  getPackage: ->
    require( './package.json' )

  getName: ->
    utils.getPackage().name

  getVersion: ->
    utils.getPackage().version

  getSha: ->
    process.env.CIRCLE_SHA1

  getBuildNum: ->
    process.env.CIRCLE_BUILD_NUM

  getArtifactsDir: ->
    process.env.CIRCLE_ARTIFACTS

  getZipFilename: ->
    "#{utils.getName()}-#{utils.getVersion()}-#{utils.getSha()}-#{utils.getBuildNum()}.zip"

  getApiDocZipFilename: ->
    "#{utils.getName()}-apidoc-#{utils.getVersion()}-#{utils.getSha()}-#{utils.getBuildNum()}.zip"

  getDeployRemotePath: ->
    switch utils.getDeploymentEnvironment()
      when 'production'
        '/var/node/api.joukou.com'
      when 'staging'
        '/var/node/staging-api.joukou.com'
      else
        throw new Error( 'Invalid deployment environment!' )

  getApiDocDeployRemotePath: ->
    switch utils.getDeploymentEnvironment()
      when 'production'
        '/var/www/apidoc.joukou.com'
      when 'staging'
        '/var/www/staging-apidoc.joukou.com'
      else
        throw new Error( 'Invalid deployment environment!' )

  getScpCommand: ( { host } ) ->
    [
      'scp'
      '-o'
      'IdentityFile=/home/ubuntu/.ssh/id_joukou.com'
      '-o'
      'ControlMaster=no'
      path.join( utils.getArtifactsDir(), utils.getZipFilename() )
      "node@#{host}:#{path.join( '/tmp', utils.getZipFilename() )}"
    ].join( ' ' )

  getApiDocScpCommand: ( { host } ) ->
    [
      'scp'
      '-o'
      'IdentityFile=/home/ubuntu/.ssh/id_joukou.com'
      '-o'
      'ControlMaster=no'
      path.join( utils.getArtifactsDir(), utils.getApiDocZipFilename() )
      "www-data@#{host}:#{path.join( '/tmp', utils.getApiDocZipFilename() )}"
    ].join( ' ' )

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
    )
    plugins.util.log( 'apidoc:' + count )
    done()

  deployZip: ->
    gulp.src( '**/*' )
      .pipe( plugins.grepStream( '**/dist/apidoc/**/*', invertMatch: true ) )
      .pipe( plugins.zip( utils.getZipFilename() ) )
      .pipe( gulp.dest( utils.getArtifactsDir() ) )

  deployApiDocZip: ->
    gulp.src( 'dist/apidoc/**/*' )
      .pipe( plugins.zip( utils.getApiDocZipFilename() ) )
      .pipe( gulp.dest( utils.getArtifactsDir() ) )

  deployUploadAkl1: ( done ) ->
    exec( utils.getScpCommand( host: 'akl1.joukou.com' ), ( err, stdout, stderr ) ->
      plugins.util.log( stdout )
      plugins.util.log( stderr )
      done( err )
    )

  deployUploadAkl2: ( done ) ->
    exec( utils.getScpCommand( host: 'akl2.joukou.com' ), ( err, stdout, stderr ) ->
      plugins.util.log( stdout )
      plugins.util.log( stderr )
      done( err )
    )

  deployUploadAkl3: ( done ) ->
    exec( utils.getScpCommand( host: 'akl3.joukou.com' ), ( err, stdout, stderr ) ->
      plugins.util.log( stdout )
      plugins.util.log( stderr )
      done( err )
    )

  deployApiDocUploadAkl1: ( done ) ->
    exec( utils.getApiDocScpCommand( host: 'akl1.joukou.com' ), ( err, stdout, stderr ) ->
      plugins.util.log( stdout )
      plugins.util.log( stderr )
      done( err )
    )

  deployApiDocUploadAkl2: ( done ) ->
    exec( utils.getApiDocScpCommand( host: 'akl2.joukou.com' ), ( err, stdout, stderr ) ->
      plugins.util.log( stdout )
      plugins.util.log( stderr )
      done( err )
    )

  deployApiDocUploadAkl3: ( done ) ->
    exec( utils.getApiDocScpCommand( host: 'akl3.joukou.com' ), ( err, stdout, stderr ) ->
      plugins.util.log( stdout )
      plugins.util.log( stderr )
      done( err )
    )

  deployCommandsAkl1: ->
    plugins.ssh.exec(
      command: [
        "rm -rf #{path.join( utils.getDeployRemotePath(), '*' )}"
        "unzip /tmp/#{utils.getZipFilename()} -d #{utils.getDeployRemotePath()}"
      ]
      sshConfig:
        host: 'akl1.joukou.com'
        port: 22
        username: 'node'
        privateKey: fs.readFileSync( '/home/ubuntu/.ssh/id_joukou.com' ).toString()
    )

  deployCommandsAkl2: ->
    plugins.ssh.exec(
      command: [
        "rm -rf #{path.join( utils.getDeployRemotePath(), '*' )}"
        "unzip /tmp/#{utils.getZipFilename()} -d #{utils.getDeployRemotePath()}"
      ]
      sshConfig:
        host: 'akl2.joukou.com'
        port: 22
        username: 'node'
        privateKey: fs.readFileSync( '/home/ubuntu/.ssh/id_joukou.com' ).toString()
    )

  deployCommandsAkl3: ->
    plugins.ssh.exec(
      command: [
        "rm -rf #{path.join( utils.getDeployRemotePath(), '*' )}"
        "unzip /tmp/#{utils.getZipFilename()} -d #{utils.getDeployRemotePath()}"
      ]
      sshConfig:
        host: 'akl3.joukou.com'
        port: 22
        username: 'node'
        privateKey: fs.readFileSync( '/home/ubuntu/.ssh/id_joukou.com' ).toString()
    )

  deployApiDocCommandsAkl1: ->
    plugins.ssh.exec(
      command: [
        "rm -rf #{path.join( utils.getApiDocDeployRemotePath(), '*' )}"
        "unzip /tmp/#{utils.getApiDocZipFilename()} -d #{utils.getApiDocDeployRemotePath()}"
      ]
      sshConfig:
        host: 'akl1.joukou.com'
        port: 22
        username: 'www-data'
        privateKey: fs.readFileSync( '/home/ubuntu/.ssh/id_joukou.com' ).toString()
    )

  deployApiDocCommandsAkl2: ->
    plugins.ssh.exec(
      command: [
        "rm -rf #{path.join( utils.getApiDocDeployRemotePath(), '*' )}"
        "unzip /tmp/#{utils.getApiDocZipFilename()} -d #{utils.getApiDocDeployRemotePath()}"
      ]
      sshConfig:
        host: 'akl2.joukou.com'
        port: 22
        username: 'www-data'
        privateKey: fs.readFileSync( '/home/ubuntu/.ssh/id_joukou.com' ).toString()
    )

  deployApiDocCommandsAkl3: ->
    plugins.ssh.exec(
      command: [
        "rm -rf #{path.join( utils.getApiDocDeployRemotePath(), '*' )}"
        "unzip /tmp/#{utils.getApiDocZipFilename()} -d #{utils.getApiDocDeployRemotePath()}"
      ]
      sshConfig:
        host: 'akl3.joukou.com'
        port: 22
        username: 'www-data'
        privateKey: fs.readFileSync( '/home/ubuntu/.ssh/id_joukou.com' ).toString()
    )

  deployNotification: ( done ) ->
    requestOptions =
      uri: 'https://api.flowdock.com/v1/messages/team_inbox/87d6d03d770e3ea007f7fe747fede5f4'
      method: 'POST'
      json:
        source: 'Circle'
        from_address: 'deploy+ok@joukou.com'
        subject: "Success: deployment to #{utils.getDeploymentEnvironment()} from build \##{utils.getBuildNum()}"
        content: '''
                 <b>joukou-api</b> has been deployed to https://staging-api.joukou.com.
                 '''
        from_name: ''
        project: 'joukou-api'
        tags: [ '#deploy', "\##{utils.getDeploymentEnvironment()}" ]
        link: 'http://staging-api.joukou.com'
    request( requestOptions, ->
      done()
    )
    return

  deployApiDocNotification: ( done ) ->
    requestOptions =
      uri: 'https://api.flowdock.com/v1/messages/team_inbox/87d6d03d770e3ea007f7fe747fede5f4'
      method: 'POST'
      json:
        source: 'Circle'
        from_address: 'deploy+ok@joukou.com'
        subject: "Success: deployment to #{utils.getDeploymentEnvironment()} from build \##{utils.getBuildNum()}"
        content: '''
                 <b>joukou-api</b> has been deployed to https://staging-apidoc.joukou.com.
                 '''
        from_name: ''
        project: 'joukou-api'
        tags: [ '#deploy', "\##{utils.getDeploymentEnvironment()}" ]
        link: 'http://staging-apidoc.joukou.com'
    request( requestOptions, ->
      done()
    )
    return

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


gulp.task( 'zip:deploy', tasks.deployZip )
gulp.task( 'upload-akl1:deploy', [ 'zip:deploy' ], tasks.deployUploadAkl1 )
gulp.task( 'upload-akl2:deploy', [ 'zip:deploy' ], tasks.deployUploadAkl2 )
gulp.task( 'upload-akl3:deploy', [ 'zip:deploy' ], tasks.deployUploadAkl3 )
gulp.task( 'upload:deploy', [ 'upload-akl1:deploy', 'upload-akl2:deploy', 'upload-akl3:deploy' ] )
gulp.task( 'commands-akl1:deploy', [ 'upload:deploy' ], tasks.deployCommandsAkl1 )
gulp.task( 'commands-akl2:deploy', [ 'upload:deploy' ], tasks.deployCommandsAkl2 )
gulp.task( 'commands-akl3:deploy', [ 'upload:deploy' ], tasks.deployCommandsAkl3 )
gulp.task( 'commands:deploy', [ 'commands-akl1:deploy', 'commands-akl2:deploy', 'commands-akl3:deploy' ] )
gulp.task( 'notification:deploy', [ 'commands:deploy' ], tasks.deployNotification )


gulp.task( 'zip:deploy-apidoc', tasks.deployApiDocZip )
gulp.task( 'upload-akl1:deploy-apidoc', [ 'zip:deploy-apidoc' ], tasks.deployApiDocUploadAkl1 )
gulp.task( 'upload-akl2:deploy-apidoc', [ 'zip:deploy-apidoc' ], tasks.deployApiDocUploadAkl2 )
gulp.task( 'upload-akl3:deploy-apidoc', [ 'zip:deploy-apidoc' ], tasks.deployApiDocUploadAkl3 )
gulp.task( 'upload:deploy-apidoc', [ 'upload-akl1:deploy-apidoc', 'upload-akl2:deploy-apidoc', 'upload-akl3:deploy-apidoc' ] )
gulp.task( 'commands-akl1:deploy-apidoc', [ 'upload:deploy-apidoc' ], tasks.deployApiDocCommandsAkl1 )
gulp.task( 'commands-akl2:deploy-apidoc', [ 'upload:deploy-apidoc' ], tasks.deployApiDocCommandsAkl2 )
gulp.task( 'commands-akl3:deploy-apidoc', [ 'upload:deploy-apidoc' ], tasks.deployApiDocCommandsAkl3 )
gulp.task( 'commands:deploy-apidoc', [ 'commands-akl1:deploy-apidoc', 'commands-akl2:deploy-apidoc', 'commands-akl3:deploy-apidoc' ] )
gulp.task( 'notification:deploy-apidoc', [ 'commands:deploy-apidoc' ], tasks.deployNotification )


gulp.task( 'deploy', [ 'notification:deploy', 'notification:deploy-apidoc' ] )

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