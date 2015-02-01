
## Summary

Tiny flow with conditional branching.

## Installation

    npm install flat-flow --save

## Usage

    { flow } = require 'flat-flow'

    # This is how to use me.
    flow [

      # 1-arity functions will be called and result merged.
      (done) ->
        done null, { a: 1 }

      # If you pass an error as first arg, the whole flow is finished, see the bottom.
      (done) ->
        done null, { b: 2 }

      # 0-arity function returning booleans manage flow, false will skipp all calls until true is found in 0-arity.
      -> false

      # Will be skipped.
      (done) ->
        done null, { c: 3 }

      # Resume flow. You always have access to locals set before.
      -> true or @a is 1

      # Will be called because we've resumed above.
      (done) ->
        done null, { e: @a + @b }

      # 2-arity functions allows you to refer to locals if you don't want to bind all nested functions.
      (done, { e }) ->
        process.nextTick ->
          process.nextTick ->
            done null, { f: e + 1 }

    ], (err) ->
      assert.ifError err
      assert.equal @a, 1
      assert.equal @b, 2
      assert.equal @c, undefined
      assert.equal @d, undefined
      assert.equal @e, 3
      assert.equal @f, 4
