
## Summary

Tiny flow with conditional branching.

## Installation

    npm install flat-flow --save

## Usage

    { flow } = require 'flat-flow'

    # This is how to use me.
    flow [

      # 1-arity functions are called and result from (err, result) merged with locals.
      # If you pass an error as first arg, the whole flow will be finished, see the bottom.
      (done) ->
        done null, { a: 1, b: 2 }

      # 0-arity functions that return boolean manage the flow; false will all calls until true is found in 0-arity.
      -> false

      # Will be skipped.
      (done) ->
        done null, { c: 3 }

      # Resume flow. You have access to locals merged before.
      -> @a is 1

      # Will be called because we resumed the flow above.
      (done) ->
        done null, { e: @a + @b }

      # 2-arity functions allows you to refer to locals if you don't want to bind all nested functions.
      (done, { e }) ->
        process.nextTick ->
          process.nextTick ->
            done null, { f: e + 1 }

      # ...otherwise you can use locals directly
      (done) ->
        process.nextTick => # fat
          process.nextTick => # fat
            done null, { g: @f + 1 }

    ], (err, { e, f }) -> # final callback, always called.
      assert.ifError err

      # Locals are here as well.
      assert.equal @a, 1
      assert.equal @b, 2
      assert.equal @c, undefined
      assert.equal @d, undefined

      # Or you can access them from optional 2nd argument.
      assert.equal e, 3
      assert.equal f, 4

      assert.equal @g, 5
