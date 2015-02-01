
# npm install flat-flow mongodb

{ flow } = require '../src' # 'flat-flow'
mongodb = require 'mongodb'

flow [

  # Connect to MongoDB.
  (done) ->
    mongodb.connect 'mongodb://localhost/test', (err, db) ->
      done err, { db }

  # Get timestamp from MongoDB.
  (done, { db }) ->
    db.eval 'return new Date()', (err, timestamp) ->
      done err, { timestamp }

  # List databases.
  (done) ->
    @db.admin().listDatabases (err, dbs) ->
      done err, { dbs }

], (err, { dbs }) ->
  unless err?
    console.log 'timestamp', @timestamp
    console.log 'dbs', dbs
    @db.close()
  else
    console.error err
