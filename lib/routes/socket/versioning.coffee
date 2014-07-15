fs = require 'fs'
fspath = require 'path'
async = require 'async'
mkdirp = require 'mkdirp'
xd = require 'xdiff'
util = require 'util'

###*
* @type {string}
###
reposDir = fspath.resolve __dirname, '../../../data/versions'

###*
* Returns list of repos
###
exports.getRepos = (cb) ->
  fs.readdir reposDir, (err, repos) ->
    unless err? then cb null, repos
    else if err.code isnt 'ENOENT' then cb err
    else mkdirp reposDir, (err) -> 
      if err then cb(err) else cb null, []

###*
* Returns list of versions at repo
*
* @param {string} repo
###
exports.readRepo = (repo, cb) ->
  fs.readdir fspath.join(reposDir, repo), (err, versions) ->
    if err then return cb err

    versions = versions.sort (v1, v2) -> Number(v1) > Number(v2)
    async.mapSeries versions, (vers, cb2) ->
      readVersionFile repo, vers, (err, versData) ->
        if err? then return cb2 err      
        cb2 null, {date: vers, descr: versData.descr}
    , cb

###*
* Add version to repository
###
exports.addVersion = (repo, data, cb) ->
  dir = fspath.join(reposDir, repo)
  console.log util.inspect data
  async.waterfall [
    async.apply mkdirp, dir
    (dir, cb) -> cb()
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
      readVersionFile repo, versions[0].date, (err, original) ->
        if err then return cb err

        # requested first version that contain full content, so response it
        if version is versions[0].date then return cb null, original

        readVersionFile repo, version, (err, versionDiff) ->
          if err then return cb err
          
          console.log  'appling patch'
          console.log util.inspect versionDiff.model
          console.log '\nto\n'
          util.inspect original.model 
          model = xd.patch original.model, versionDiff.model
          cb null, {
            model: model 
            descr: versionDiff.descr
          } 

    else if versions.length is 1
      if version isnt versions[0].date
        return cb "Versions doesnt match: #{version}-#{versions[0].date}"
      
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
  versName = date.getTime().toString()

  if versions.length > 0
    readVersionFile repo, versions[0].date, (err, origContent) ->
      if err then return cb err

      newVersion = 
        model: xd.diff origContent.model, data.model
        descr: data.descr

      writeVersion repo, versName, newVersion, cb
  else 
    writeVersion repo, versName, data, cb

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