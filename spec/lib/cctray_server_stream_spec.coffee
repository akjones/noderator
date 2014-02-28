Bacon = require "baconjs"
request = require "request"
sinon = require "sinon"

cc = null
clock = null
theStream = null

describe "#httpResponseStream", ->
  beforeEach ->
    sinon.spy Bacon, "fromBinder"
    sinon.spy Bacon, "Error"
    sinon.stub request, "get"
    clock = sinon.useFakeTimers()

    cc = require "../../lib/cctray_server_stream.js.coffee"

    theStream = cc.httpResponseStream "someurl"

  afterEach ->
    Bacon.fromBinder.restore()
    Bacon.Error.restore()
    request.get.restore()
    clock.restore()

  it "should create a stream", ->
    expect(Bacon.fromBinder.called).toBe true

  it "should request a new status every 5 seconds", ->
    Bacon.fromBinder.yield()

    clock.tick 10000

    expect(request.get.calledTwice).toBe true

  it "should emit responses into the stream", ->
    theStream.onValue (value) ->
      expect(value).toEqual "a thing"

    clock.tick 5000

    expect(request.get.calledWith("someurl")).toBe true
    request.get.yield null, {}, "a thing"

  it "should emit errors if the request has issues", ->
    theStream.onError (error) ->
      expect(error).toEqual "damn, you suck"

    clock.tick 5000

    request.get.yield "damn, you suck", {}, {}
    expect(Bacon.Error.calledWith("damn, you suck")).toBe true
