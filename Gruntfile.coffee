chai = require 'chai'
sinonChai = require 'sinon-chai'

module.exports = (grunt) ->
  # load plugins that provides tasks  
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-closure-tools'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-mocha-cli'
  grunt.loadNpmTasks 'grunt-reactjsx'
  grunt.loadNpmTasks 'grunt-mocha-phantomjs'

  # tasks aliases
  grunt.registerTask 'deps', ['esteDeps']
  grunt.registerTask 'build', ['coffee2closure', 'closureBuilder']

  grunt.registerTask 'test', ['coffee:test','esteUnitTests']

  # task for heroku deployment
  grunt.registerTask 'heroku:development', ['coffee:app', 'deps']

  grunt.initConfig
    coffee:
      options:
        compile: true
        bare: true

      app:
        files: [{
          expand: true,
          src: [
            './*.coffee'
            '!./Gruntfile.coffee'
            './lib/**/*.coffee'
            './public/scripts/**/*.coffee'
          ]
          ext: '.js'
        }]
      test:
        expand: true,
        src: ['test/unit/**/*.coffee'],
        ext: '.js'

    reactjsx:
      all:
        files: [{
          expand: true,
          src: [
            './public/scripts/dm/ui/**/*.js'
          ]
          ext: '.js'
        }]

    esteDeps:
      all:
        options:
          outputFile: 'public/scripts/dm/deps.js'
          prefix: '../../../../'
          root: [
            'bower_components/closure-library'
            'bower_components/este-library/este/thirdparty'
            'public/scripts/dm'
          ]

    coffee2closure:
      app:
        files: '<%= coffee.app.files %>'

    closureBuilder:
      options:
        closureLibraryPath: 'bower_components/closure-library'
        inputs: './public/scripts/dm/app.js'
        namespaces: 'dm'

        # [OPTIONAL] The location of the compiler.jar
        # This is required if you set the option "compile" to true.
        compilerFile: 'bower_components/closure-compiler/compiler.jar',

        # [OPTIONAL] output_mode can be 'list', 'script' or 'compiled'.
        #    If compile is set to true, 'compiled' mode is enforced.
        #    Default is 'script'.
        #output_mode: '',

        # [OPTIONAL] if we want builder to perform compile
        compile: true

        compilerOpts: 
          compilation_level: 'ADVANCED_OPTIMIZATIONS'
          #compilation_level: 'SIMPLE_OPTIMIZATIONS',
          externs: [
            'bower_components/este-library/externs/react.js'
            'bower_components/socket.io-externs/socket.io-externs.js'
          ]
          define: ["'goog.DEBUG=false'"]
          warning_level: 'verbose'
          jscomp_off: 'globalThis'
          extra_annotation_name: 'jsx'

        #execOpts:
        #   maxBuffer: 999999 * 1024
      
      all:
        src: '<%= esteDeps.all.options.root %>'
        dest: './public/scripts/modeler.min.js'

    esteUnitTests:
      options:
        depsPath: '<%= esteDeps.all.options.outputFile %>'
        prefix: '<%= esteDeps.all.options.prefix %>'
      
        mocha: do ->
          global.expect = chai.expect
          chai.use sinonChai
          chai.should()

          ui: 'bdd'
          reporter: 'spec'
          globals: []
          timeout: 100
          bail: true
        
      src: ['test/unit/**/*_test.js']

    mochacli:
      options:
        reporter: 'spec',
        ui: 'bdd'
        compilers: ['coffee:coffee-script/register']
        bail: true
        colors: true
        require: ['./test/common.js']
      
      src: 'test/unit/lib/**/*Test.coffee'

    mocha_phantomjs:
      options:
        'reporter': 'spec',
      all: ['test/**/*Test.html']

    stylus:
      options:
        compile: true
        use: [ require('nib') ]
      compile:
        files: 
          'public/styles/main.css': 'public/styles/main.styl'

    watch:
      coffee:
        files: [
         './*.coffee'
          '!./Gruntfile.coffee'
          './lib/**/*.coffee'
          './public/scripts/**/*.coffee'
        ] #'<%= coffee.app.files[0].src %>'
        tasks: ['coffee:app', 'reactjsx:all']
        options:
          livereload: true

      test:
        files: [
          'lib/**/*.coffee'
          'public/scripts/**/*.coffee'
          'test/unit/**/*.coffee'
          'test/unit/**/*Test.html'
        ]
        tasks: [
          'coffee:app', 'reactjsx'
          'coffee:test'
          'test', 'mocha_phantomjs', 'mochacli'
        ]        
        options:
          livereload: true
          