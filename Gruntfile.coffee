module.exports = (grunt) ->

  grunt.initConfig
    closureSoys:
      all:
        src: './public/scripts/templates/**/*.soy'
        soyToJsJarPath: '/srv/www/GoogleClosure/templates/SoyCompiler/SoyToJsSrcCompiler.jar'
        outputPathFormat: '{INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js'
        options:
          shouldGenerateJsdoc: true
          shouldProvideRequireSoyNamespaces: true

    closureDepsWriter:
      options:
        closureLibraryPath: './public/scripts/lib'
        root_with_prefix: '"/srv/git/modeler/public/scripts ../../.."'

      all:
        dest: '/srv/git/modeler/public/scripts/app-deps.js'

    closureBuilder:
      options:
        closureLibraryPath: 'public/scripts/lib'
        inputs: './public/scripts/app.js'

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
        src: './public/scripts'
        dest: './public/scripts/modeler.min.js'

  # load plugins that provides tasks
  grunt.loadNpmTasks 'grunt-closure-soy'
  grunt.loadNpmTasks 'grunt-closure-tools'

  # define tasks
  grunt.registerTask('default', ['closureSoys','closureDepsWriter']);

  # tasks aliases
  grunt.registerTask('deps', ['closureDepsWriter']);  
  grunt.registerTask('soy', ['closureSoys']);
  grunt.registerTask('build', ['closureBuilder']);