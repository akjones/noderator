Bacon = require "baconjs"
request = require "request"
sinon = require "sinon"

baseStreams = null
clock = null
polledStream = null

describe "base streams", ->
  beforeEach ->
    sinon.spy Bacon, "fromBinder"
    sinon.spy Bacon, "Error"
    sinon.stub request, "get"
    clock = sinon.useFakeTimers()

    baseStreams = require "../../lib/base_streams.js.coffee"

  afterEach ->
    Bacon.fromBinder.restore()
    Bacon.Error.restore()
    request.get.restore()
    clock.restore()

  describe "#splitStream", ->
    splitStream = null

    beforeEach ->
      splitStream = baseStreams.splitStream { "url": "someurl", "whodat": "someguy" }

    it "should create a stream", ->
      expect(Bacon.fromBinder.called).toBe true

    it "should make the request with arbitrary params", ->
      Bacon.fromBinder.yield()

      clock.tick 5000

      expect(request.get.args[0][0]["whodat"]).toEqual "someguy"
      expect(request.get.args[0][0]["url"]).toEqual "someurl"

    it "should emit errors if the request has issues", ->
      splitStream.onError (error) ->
        expect(error).toEqual "damn, you suck"

      clock.tick 5000

      request.get.yield "damn, you suck"
      expect(Bacon.Error.calledWith("damn, you suck")).toBe true

    it "should emit individual object into the stream", ->
      splitStream.take(1).onValue (value) ->
        expect(value).toEqual { status: "nope" }

      request.get.yield null, {}, [{ status: "nope" }, { status: "hell no" }]


  describe "#polledResonseStream", ->
    beforeEach ->
      polledStream = baseStreams.polledXMLStream { "url": "someurl", "User-Agent": "a fish" }

    it "should create a stream", ->
      expect(Bacon.fromBinder.called).toBe true

    it "should make a request every 5 seconds", ->
      Bacon.fromBinder.yield()

      clock.tick 10000

      expect(request.get.calledTwice).toBe true

    it "should make the request with a user agent", ->
      Bacon.fromBinder.yield()

      clock.tick 5000

      userAgent = request.get.args[0][0]["User-Agent"]
      expect(userAgent).toEqual "a fish"

    it "should emit objects into the stream", ->
      polledStream.onValue (value) ->
        expect(value).toEqual
          Projects:
            Project:
              name: "akjones/noderator"
              activity: "Sleeping"
              lastBuildStatus: "Success"

      clock.tick 5000

      url = request.get.args[0][0].url
      expect(url).toEqual "someurl"

      request.get.yield null, {}, '<Projects><Project name="akjones/noderator" activity="Sleeping" lastBuildStatus="Success" /></Projects>'

    it "should emit errors if the request has issues", ->
      polledStream.onError (error) ->
        expect(error).toEqual "damn, you suck"

      clock.tick 5000

      request.get.yield "damn, you suck"
      expect(Bacon.Error.calledWith("damn, you suck")).toBe true
