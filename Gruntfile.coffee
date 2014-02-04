chai = require 'chai'
sinonChai = require 'sinon-chai'

module.exports = (grunt) ->
  # load plugins that provides tasks
  grunt.loadNpmTasks 'grunt-closure-soy'
  grunt.loadNpmTasks 'grunt-closure-tools'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este'

  # define tasks
  grunt.registerTask('default', ['closureSoys','closureDepsWriter']);

  # tasks aliases
  grunt.registerTask('deps', ['esteDeps']);  
  grunt.registerTask('soy', ['closureSoys']);
  grunt.registerTask('build', ['closureBuilder']);

  grunt.registerTask('test',['coffee:test','esteUnitTests'])
  
  srcCoffees = [
    './*.coffee'
    'src/**/*.coffee'
    'public/scripts/**/*.coffee'
  ]

  grunt.initConfig
    coffee:
      options:
        compile: true
        bare: true

      run:
        expand: true,
        src: srcCoffees,
        ext: '.js'
      test:
        expand: true,
        src: ['test/unit/**/*.coffee'],
        ext: '.js'

    closureSoys:
      all:
        src: './public/scripts/dm/templates/**/*.soy'
        soyToJsJarPath: '/srv/www/GoogleClosure/templates/SoyCompiler/SoyToJsSrcCompiler.jar'
        outputPathFormat: '{INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js'
        options:
          shouldGenerateJsdoc: true
          shouldProvideRequireSoyNamespaces: true

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

    watch:
      coffee:
        files: srcCoffees
        tasks: ['coffee']
        options:
          livereload: true

      test:
        files: [
          'public/scripts/**/*.coffee'
          'test/unit/**/*.coffee'
        ]
        tasks: ['test']