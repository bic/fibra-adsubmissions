_= lodash
  
compile_key = (key)->
  keys = key.split '.'
  path_elms = form_ui.data_path()
  compiled=[]
  for  path_elm, i in path_elms
    if i==keys.length
      break
    else
      compiled.push path_elm
      unless keys[i] == '$' or keys[i] == path_elm
        debugger
  if keys.length > compiled.length
    compiled.push keys[compiled.length...]...
  return compiled
_.extend ReactiveForms.details ,
  dotNotationToObject: (key, val)->
    unless val? and key?
      return 
    _.set {} , compile_key(key),val
  dotNotationToValue: (obj,key)->
    unless obj? and key?
      return 
    path = compile_key(key)
    return _.get obj,path
  deleteByDotNotation: _.wrap  ReactiveForms.details.deleteByDotNotation , (orig,obj,key)->
    unless obj? and key?
      return 
    orig.call this , obj, compile_key(key).join('.')

### 
  dotNotationToValue:
  deleteByDotNotation:
  deepExtendObject:
###


