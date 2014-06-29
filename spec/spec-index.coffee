
assert = require 'assert'
async = require 'async'
{ flow } = require '../src'

describe 'flow', ->

  it 'should invoke stuff', ->

    flow [

      # After async call is finished, you pass result object.
      # Each attribute will be available as local, bound to this.
      (done) ->
        done null, { a: 1 }

      (done) ->
        done null, { b: 2 }

      # Arity 0 calls manage control flow. If false is returned
      # any following (non-arity 0) calls are skipped.
      -> false

      # This call is going to be skipped because of the conditional above.
      (done) ->
        done null, { c: 3 }

      # Also skipped.
      (done) ->
        done null, { d: -1 }

      # Another conditional, re-enables calls again.
      -> true

      # This will be called. All previously set locals are available, bound
      # to this.
      (done) ->
        done null, { e: @a + @b }

    ], (err) ->
      assert.ifError err
      assert.equal @a, 1
      assert.equal @b, 2
      assert.equal @c, undefined
      assert.equal @d, undefined
      assert.equal @e, 3

  it 'should perform series of tasks', (done) ->
    [ a, b, c ] = [ false, false, false ]
    flow [

      (done) ->
        async.nextTick ->
          a = 1
          done null

      (done) ->
        async.nextTick ->
          b = 2
          done null

      (done) ->
        async.nextTick ->
          c = 3
          done null

    ], (err) ->
      assert.ifError err
      assert.equal 1, a
      assert.equal 2, b
      assert.equal 3, c
      done null

  it 'should skip in control flow', (done) ->

    ab = []

    flow [

      # Set our condition
      (done) -> done null, { myCond: false }

      # Skip
      -> @myCond

      # Won't be called.
      (done) ->
        ab.push 'SKIPPED'
        done null

      # Conditional, should process the rest.
      -> not @myCond

      # This should be called.
      (done) ->
        ab.push 'OK'
        done null

    ], (err) ->
      assert.ifError err
      assert.equal false, @myCond
      assert.deepEqual ['OK'], ab
      done null

  it 'should start with locals', (done) ->
    flow { foo: 3 }, [

      (done) ->
        async.nextTick ->
          done null, { bar: 5 }

    ], (err) ->
      assert.ifError err
      assert.equal @foo, 3
      assert.equal @bar, 5
      assert.deepEqual Object.keys(@).sort(), [ 'bar', 'foo' ]
      done null

  # it 'should compose flows', (done) ->
  #
  #   flows:
  #     isoTimestamp:
  #       [
  #         (done) -> done null, { timestamp: 1402322190524 }
  #         (done) -> done null, { iso: new Date(@timestamp).toISOString() }
  #       ]
  #
  #   flow [
  #
  #     (done) ->
  #       flow flows.isoTimestamp, (err) ->
  #         done err, { @iso }
  #
  #     flows.htmlTag
  #   ], (err) ->
