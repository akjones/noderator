request = require("request")
Bacon = require("baconjs").Bacon
_ = require("lodash")
{parseString} = require "xml2js"

module.exports =
  polledXMLStream: (requestParams) ->
    Bacon.fromBinder (sink) ->
      timer = setInterval ->
        request.get requestParams, (error, response, body) ->
          if error
            sink new Bacon.Error(error)
          else
            parseString body, { explicitArray: false, mergeAttrs: true }, (error, result) ->
              sink result
      , 5000
      -> clearInterval timer

  splitStream: (requestParams) ->
    Bacon.fromBinder (sink) ->
      request.get requestParams, (error, response, body) ->
        if error
          sink new Bacon.Error(error)
        else
          _.forEach body, (obj) ->
           sink obj
      ->
