S = require './util/low_level_store'

module.exports = ( { key, read, write } ) ->
  read ?= JSON.parse
  write ?= JSON.stringify
  (v) ->
    if arguments.length is 0 # f() -> get
      if ( v = S key )?
        read v
      else
        undefined
    else
      if v?
        S key, write v
      else
        S key, null