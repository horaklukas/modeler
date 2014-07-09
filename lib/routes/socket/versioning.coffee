fs = require 'fs'
fspath = require 'path'
async = require 'async'
mkdirp = require 'mkdirp'
xd = require 'xdiff'

###*
* @type {string}
###
reposDir = fspath.resolve __dirname, '../../../data/versions'

###*
* Returns list of repos
###
exports.getRepos = (cb) ->
  fs.readdir reposDir, cb

###*
* Returns list of versions at repo
*
* @param {string} repo
###
exports.readRepo = (repo, cb) ->
  fs.readdir fspath.join(reposDir, repo), (err, versions) ->
    if err then return cb err

    cb null, versions.sort (v1, v2) -> 
      Number(v1) > Number(v2)

###*
* Add version to repository
###
exports.addVersion = (repo, data, cb) ->
  dir = fspath.join(reposDir, repo)

  async.waterfall [
    async.apply mkdirp, dir
    async.apply exports.readRepo, repo
    async.apply createVersion, repo, data
  ], cb

###*
*
###
exports.getVersion = (repo, version, cb) ->
  exports.readRepo repo, (err, versions) ->
    if err then return cb err

    if versions.length > 1
      readVersionFile repo, versions[0], (err, original) ->
        if err then return cb err

        readVersionFile repo, version, (err, versionDiff) ->
          if err then return cb err
          else cb null, xd.patch(original, versionDiff)

    else if versions.length is 1
      if version isnt versions[0]
        return cb "Versions doesnt match: #{version}-#{versions[0]}"
      
      readVersionFile repo, version, cb
    else
      cb 'Repo doesnt contain any version'

readVersionFile = (repo, version, cb) ->
  options = encoding: 'utf8'

  fs.readFile getVersionPath(repo, version), options, (err, content) ->
    if err then return cb err
    else 
      try cb(null, JSON.parse content) catch err then cb err

###*
* Complete version name and data and create write of version file
###
createVersion = (repo, data, versions, cb) ->
  date = new Date
  newVersion = date.getTime().toString()

  if versions.length > 0
    readVersionFile repo, versions[0], (err, origContent) ->
      if err then return cb err
      writeVersion repo, newVersion, xd.diff(origContent, data), cb
  else 
    writeVersion repo, newVersion, data, cb

###*
* Write version content do file system
*
* @param {string} repo Name of repository
* @param {string} version Name of version file
* @param {Object} content Version content
###
writeVersion = (repo, version, content, cb) ->
  stringifiedContent = JSON.stringify(content)
  unless stringifiedContent then return cb "Wrong version data: #{content}"

  fs.writeFile getVersionPath(repo, version), stringifiedContent, cb


###*
* @return {string}
###
getVersionPath = (repo, version) ->
  fspath.join reposDir, repo, version 