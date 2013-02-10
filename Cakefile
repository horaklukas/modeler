{spawn, exec} = require 'child_process'
utils = require 'util' 

mochabin = 'node_modules/mocha/bin/mocha'


task 'test', 'run tests once', ->
	execBin mochabin

task 'watchtest', 'run tests and watch changes', ->
	execBin mochabin, ['-w']

###*
* @param {String} bin Path to binary
* @param {Array} args List of arguments to pass after command
###
execBin = (bin, args = []) ->
	if not bin? then console.error 'Path to binary not passed'
	if not utils.isArray args
		console.error 'Binary arguments have to be an array'

	cmd = spawn bin, args

	cmd.stdout.pipe process.stdout
	cmd.stderr.pipe process.stderr
	cmd.on 'exit', (data) -> console.log "#{bin} ended "