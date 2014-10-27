
async = require 'async'

# Merge locals.
merge = (a = {}, b = {}) ->
  for k, v of b
    if b.hasOwnProperty k
      a[ k ] = v
  a

# Async control flow.
#
# @param [Object]
# @param []
flow = (self = {}, functions, done) ->
  [ self, functions, done ] = [ {}, self, functions ] if Array.isArray self

  # Clone, hold this reference.
  self = merge {}, self

  map = (f, r) ->
    switch

      # TODO: push/pop state
      when Array.isArray f
        # r.push (done) -> self.pushState(...)
        f.forEach (g) ->
          map g, r
        # r.pop (done) -> self.popState(...)

      when typeof f is 'function'
        switch f.length

          when 0
            r.push (done) ->

              # self.__flowSkip = not f.bind(self)()

              result = f.bind(self)()

              switch
                when result in [ true, false ]
                  self.__flowSkip = not result

                when (typeof result is 'object') and (not Array.isArray(result))
                  unless self.__flowSkip
                    merge self, result

                else
                  throw new Error "Arity 0 flow function has to return {} or true/false."

              # TODO: process.nextTick?
              done null

          when 1
            r.push (done) ->
              unless self.__flowSkip
                f.bind(self) (err, result) ->

                  # NOTE: We're merging (potentially replacing result) even
                  #       in case of errors.
                  merge self, result
                  done err
              else
                done null

          else
            throw new Error "Wrong arity (#{f.length}) in flow for: #{f}"

  mapped = []
  map functions, mapped

  async.series mapped, (err) ->
    done.bind(self) err, self

module.exports = {
  flow
}
