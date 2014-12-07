
assert = require 'assert'
async = require 'async'
{ flow } = require '../src'

describe 'flow', ->

  it 'should invoke stuff', (done) ->

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
      done err

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

  it 'should pick @ reference and store it in @$', (done) ->

    class K
      @a: 123
      @b: 456
      @x: (done) ->
        flow { $: @ }, [
          (done) ->
            done null, { r: @$.a + @$.b }
        ], ->
          done null, @r

    K.x (err, r) ->
      assert.equal 579, r
      done null

  it 'should add kv', (done) ->
    flow [
      -> foo: 'abc'
      -> false
      -> bar: 'zzz'
      -> true
      -> baz: 'def'
    ], (err) ->
      assert.ifError err
      assert.equal @foo, 'abc'
      assert.equal @bar, undefined
      assert.equal @baz, 'def'
      done err

  it 'should return flow object without running it', (done) ->
    i = 0
    adder = [
      -> x: i += 1
    ]
    assert.equal i, 0
    flow adder, (err) ->
      assert.ifError err
      assert.equal i, 1
      flow [
        adder
        -> false
        -> x: i += 1
        adder
      ], (err) ->
        assert.ifError err
        assert.equal @x, 2
        done err

  it 'should return flow object without running it', (done) ->
    shift = [
      -> a: @a << 1
    ]

    ashift = [
      (done) ->
        setImmediate =>
          a = @a << 1
          done null, { a }
    ]

    flow { a: 1 }, [
      -> assert.equal(@a, 1); true
      shift
      -> assert.equal(@a, 2); true
      ashift
      -> assert.equal(@a, 4); true
    ], done

  # it 'should nest flows', (done) ->
  #
  #   flows =
  #     yep: [
  #       (done) ->
  #         setImmediate ->
  #           done null, { msg: 'yep' }
  #     ]
  #     nope: [
  #       (done) ->
  #         setImmediate ->
  #           done null, { msg: 'nope' }
  #     ]
  #     isfoo: [
  #       ->
  #         if @foo is 1
  #           flows.yep
  #         else
  #           flows.nope
  #     ]
  #
  #   flow [
  #     (done) ->
  #       flow { foo: 1 }, flows.isfoo, (err) -> done null, { first: @msg }
  #     (done) ->
  #       flow { foo: 2 }, flows.isfoo, (err) -> done null, { second: @msg }
  #   ], (err) ->
  #     assert.ifError err
  #     assert.equal @first, 'yep'
  #     assert.equal @second, 'nope'
  #     done err

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
