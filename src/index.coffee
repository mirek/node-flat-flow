async = require 'async'

flow = (self = {}, functions, done) ->
  [ self, functions, done ] = [ {}, self, functions ] if Array.isArray self

  # Merge locals
  mergeLocals = (done) ->
    (err, locals) ->
      for k, v of (locals or {})
        self[k] = v
      done err

  mapArg = (f, r) ->
    switch

      # TODO: push/pop state
      when Array.isArray f
        # r.push (done) -> self.pushState(...)
        f.forEach (g) ->
          mapArg g, r
        # r.pop (done) -> self.popState(...)

      when typeof f is 'function'
        switch f.length

          when 0
            r.push (done) ->
              self.__flowSkip = not f.bind(self)()
              done null

          when 1
            r.push (done) ->
              unless self.__flowSkip
                f.bind(self) mergeLocals(done)
              else
                done null

          else
            throw new Error "Wrong arity (#{f.length}) in flow for: #{f}"

  mapped = []
  mapArg functions, mapped

  async.series mapped, (err) ->
    done.bind(self) err, self

module.exports = {
  flow
}
