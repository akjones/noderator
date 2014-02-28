request = require("request");
Bacon = require("baconjs").Bacon;

module.exports =
  httpResponseStream: (url) ->
    Bacon.fromBinder (sink) ->
      timer = setInterval ->
        request.get url, (error, response, body) ->
          if error
            sink new Bacon.Error(error)
          else
            sink body
      , 5000
      -> clearInterval timer
