module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      run:
        expand: true,
        src: ['public/scripts/**/*.coffee'],
        ext: '.js'
        options:
          compile: true
          bare: true
      test:
        expand: true,
        src: ['test/unit/**/*.coffee'],
        ext: '.js'
        options:
          compile: true
          bare: true

    closureSoys:
      all:
        src: './public/scripts/dm/templates/**/*.soy'
        soyToJsJarPath: '/srv/www/GoogleClosure/templates/SoyCompiler/SoyToJsSrcCompiler.jar'
        outputPathFormat: '{INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js'
        options:
          shouldGenerateJsdoc: true
          shouldProvideRequireSoyNamespaces: true

    closureDepsWriter:
      options:
        closureLibraryPath: './public/scripts/lib'
        root_with_prefix: [
          '"/srv/git/modeler/public/scripts/dm ../../../dm"'
          '"/srv/git/modeler/public/scripts/lib/templates ../../templates"'
        ]

      all:
        dest: '/srv/git/modeler/public/scripts/dm/app-deps.js'

    closureBuilder:
      options:
        closureLibraryPath: 'public/scripts/lib'
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
        src: './public/scripts/dm'
        dest: './public/scripts/modeler.min.js'

    mocha_phantomjs:
      all: ['test/**/*Test.html']
      options:
        reporter: 'spec'

    watch:
      coffee:
        files: ['public/scripts/**/*.coffee']
        tasks: ['coffee']
        options:
          livereload: true

      test:
        files: [
          'public/scripts/**/*.coffee'
          'test/unit/**/*.coffee'
          'test/**/*Test.html'
        ]
        tasks: ['test']

  # load plugins that provides tasks
  grunt.loadNpmTasks 'grunt-closure-soy'
  grunt.loadNpmTasks 'grunt-closure-tools'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-mocha-phantomjs'

  # define tasks
  grunt.registerTask('default', ['closureSoys','closureDepsWriter']);

  # tasks aliases
  grunt.registerTask('deps', ['closureDepsWriter']);  
  grunt.registerTask('soy', ['closureSoys']);
  grunt.registerTask('build', ['closureBuilder']);

  grunt.registerTask('test',['coffee:test','mocha_phantomjs:all'])