request = require("request");
Bacon = require("baconjs").Bacon;

module.exports =
  httpResponseStream: (url) ->
    Bacon.fromBinder (sink) ->
      timer = setInterval ->
        options =
          "url": url
          "User-Agent": "akjones"

        request.get options, (error, response, body) ->
          if error
            sink new Bacon.Error(error)
          else
            sink body
      , 5000
      -> clearInterval timer
