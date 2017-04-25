_=lodash

class FilterCompiler
  constructor:->
    @collection_bits={}
  add:(collection_name, compiler_func)->
    @collection_bits[collection_name]?=[]
    @collection_bits[collection_name].push compiler_func
  _bit_func_ctx: (filter)->
    ret=
      $or:(cond)->
        unless filter.$and?
          filter.$and = []
        
        for and_bit in filter.$and
          if and_bit.$or?
            $or = and_bit.$or
        unless $or?
          filter.$and.push  {$or:$or=[]}
        debugger
        $or.push cond
      $and:(cond)->
        filter.$and?=[]
        filter.$and.push cond
    return ret

  compile:(collection_name,reactive_source)->
    ret= {}
    unless _.isArray @collection_bits[collection_name]
      console.warn "Collection #{collection_name} has no filters defined"
      return 
    @collection_bits[collection_name].forEach (f)=>
      bit = f.call(@_bit_func_ctx(ret),reactive_source, ret)
    if _.keys ret
      return ret
    else
      return
form_ui.filter_compiler = new FilterCompiler() 
