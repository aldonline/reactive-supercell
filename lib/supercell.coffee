cell = require 'notifying-cell'

class InvalidValueError extends Error

###
opts =
  type: 'string', '...'
  init: 'initial value'

    # a non-nullable cell will be in an InvalidValueState
    # whenever its value is null or undefined
  nullable: false

    # if a cell is strict it will throw an error when setting a value
    # otherwise it is only thrown when reading the value
  strict: false 
                
###
supercell = ( opts ) ->

  if arguments.length is 0 # cell() with no options
    opts = type: null, nullable: yes
  else
    opts = opts # cell( ... )

  # since NULL or undefined are valid initial values in some cases
  # we check for presence of init property by iterating over object keys
  has_init = 'init' of opts 
  init = opts.init
  # type
  type = opts.type or null

  # is it nullable?
  nullable = opts.nullable or false

  # catch invalid NULL values
  if ( not has_init ) and ( not nullable )
    throw new InvalidValueError "Non Nullable cells must have an init value"

  # inferr type
  if ( not type? ) and has_init
    type = typeof init
  
  # label ( used for debugging )
  label = opts.label
  check equals, 'string', yes

  # function to compare
  equals = opts.equals
  check equals, 'function', yes

  # -- STATE
  # we decorate a basic cell
  inner_cell = cell()

  # the cell function that will be returned ( closes over the above variables )
  f = ( new_value ) ->
    a = arguments
    if a.length is 0 # GET
      inner_cell()
    else if a.length is 1 # SET
      unless new_value?
        if nullable
          inner_cell new_value
        else
          inner_cell new InvalidValueError 'NULL in a non-nullable cell'
      else if new_value instanceof Error
        inner_cell new_value
      else
        # check for equality
        unless compare inner_cell.value(), new_value, { type:type, equals: equals }
          if new_value?
            # run type based validator
            try
              validate_based_on_type new_value, type
            catch e
              # if we have an error then we store the error as our value
              new_value = e
          # store value
          inner_cell new_value
    else
      throw new Error 'Cell takes 0 or 1 parameters'

  # initialize to value if passed
  if has_init then f init

  # surface decorated instance methods
  f.view = -> inner_cell.view()
  f.value     = -> inner_cell.value()

  # and some more...
  f.type      = -> type
  f.nullable  = -> nullable
  f.label     = -> label

  # return cell function
  f

validate_based_on_type = ( v, type = null ) ->
  if type?
    switch typeof type
      when 'string' # native type ( object, function, number, boolean )
        this_type = typeof v
        unless this_type is type
          throw new InvalidValueError "required value of type '#{type}'' but found '#{this_type}' = #{v}"
      else
        throw new Error 'Other types not implemented yet'
  true

compare_based_on_type = ( v1, v2 ) ->
  # for now just === but for custom types this should be configurable
  v1 is v2

compare = ( v1, v2, {equals, type} ) ->
  if equals?
    equals v1, v2
  else if type?
    compare_based_on_type v1, v2, type
  else
    v1 is v2

check = ( value, type, nullable ) -> 
  return true if ( not value? ) and nullable
  typeof value is type

module.exports = supercell
supercell.InvalidValueError = InvalidValueError