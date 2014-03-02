_ = require "lodash"
baseStreams = require "./lib/base_streams.js.coffee"

module.exports =
  baseStreams: baseStreams


buildStatus = baseStreams.polledXMLStream "https://api.travis-ci.org/repositories/akjones/noderator/cc.xml"

buildHistory = baseStreams.splitStream url: "https://api.travis-ci.org/repositories/akjones/noderator/builds", json: true

commitHistory = baseStreams.splitStream(
    url: "https://api.github.com/repos/akjones/noderator/commits"
    json: true
    headers:
      "User-Agent": "akjones"
  ).map(".commit")

fullBuildHistory = buildHistory.combine(buildHistory, _.merge)

fullBuildHistory.onValue (value) ->
  console.log "MERGED: ", value
