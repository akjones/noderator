request = require("request")
Bacon = require("baconjs").Bacon
_ = require("lodash")

module.exports =
  polledRequestStream: (requestParams) ->
    Bacon.fromBinder (sink) ->
      timer = setInterval ->
        request.get requestParams, (error, response, body) ->
          if error
            sink new Bacon.Error(error)
          else
            sink body
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
