(function() {
  var async, flow;

  async = require('async');

  flow = function(self, functions, done) {
    var mapArg, mapped, mergeLocals, _ref;
    if (self == null) {
      self = {};
    }
    if (Array.isArray(self)) {
      _ref = [{}, self, functions], self = _ref[0], functions = _ref[1], done = _ref[2];
    }
    mergeLocals = function(done) {
      return function(err, locals) {
        var k, v, _ref1;
        _ref1 = locals || {};
        for (k in _ref1) {
          v = _ref1[k];
          self[k] = v;
        }
        return done(err);
      };
    };
    mapArg = function(f, r) {
      switch (false) {
        case !Array.isArray(f):
          return f.forEach(function(g) {
            return mapArg(g, r);
          });
        case typeof f !== 'function':
          switch (f.length) {
            case 0:
              return r.push(function(done) {
                self.__flowSkip = !f.bind(self)();
                return done(null);
              });
            case 1:
              return r.push(function(done) {
                if (!self.__flowSkip) {
                  return f.bind(self)(mergeLocals(done));
                } else {
                  return done(null);
                }
              });
            default:
              throw new Error("Wrong arity (" + f.length + ") in flow for: " + f);
          }
      }
    };
    mapped = [];
    mapArg(functions, mapped);
    return async.series(mapped, function(err) {
      return done.bind(self)(err, self);
    });
  };

  module.exports = {
    flow: flow
  };

}).call(this);
