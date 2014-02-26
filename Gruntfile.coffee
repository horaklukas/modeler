chai = require 'chai'
sinonChai = require 'sinon-chai'

module.exports = (grunt) ->
  # load plugins that provides tasks  
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-closure-tools'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-mocha-cli'

  # define tasks
  grunt.registerTask('default', ['esteTemplates','closureDepsWriter']);

  # tasks aliases
  grunt.registerTask('deps', ['esteDeps']);  
  grunt.registerTask('soy', ['esteTemplates']);
  grunt.registerTask('build', ['closureBuilder']);

  grunt.registerTask('test',['coffee:test','esteUnitTests'])

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

    esteTemplates:
      all:
        src: './public/scripts/dm/templates/**/*.soy'
        outputPathFormat: '{INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js'

    esteDeps:
      all:
        options:
          outputFile: 'public/scripts/dm/deps.js'
          prefix: '../../../../'
          root: [
            'bower_components/closure-library'
            'bower_components/closure-templates'
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

        # [OPTIONAL] The location of the compiler.jar
        # This is required if you set the option "compile" to true.
        #compilerFile: 'path/to/compiler.jar',

        # [OPTIONAL] output_mode can be 'list', 'script' or 'compiled'.
        #    If compile is set to true, 'compiled' mode is enforced.
        #    Default is 'script'.
        #output_mode: '',

        # [OPTIONAL] if we want builder to perform compile
        compile: false

        compilerOpts: null
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

      src: 'test/unit/**/*Test.js'

    watch:
      coffee:
        files: [
         './*.coffee'
          '!./Gruntfile.coffee'
          './lib/**/*.coffee'
          './public/scripts/**/*.coffee'
        ] #'<%= coffee.app.files[0].src %>'
        tasks: ['coffee:app']
        options:
          livereload: true

      test:
        files: [
          'lib/**/*.coffee'
          'public/scripts/**/*.coffee'
          'test/unit/**/*.coffee'
        ]
        tasks: ['coffee:app','coffee:test','test', 'mochacli']