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

      targetName:
        dest: '/srv/git/modeler/public/scripts/app-deps.js'

  # load plugins that provides tasks
  grunt.loadNpmTasks 'grunt-closure-soy'
  grunt.loadNpmTasks 'grunt-closure-tools'

  # define tasks
  grunt.registerTask('default', ['closureSoys','closureDepsWriter']);