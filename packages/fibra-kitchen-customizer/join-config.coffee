_= lodash
glob=this
fs_collection_schema_defs = [
      selector: 
        draft:true
      schema: new SimpleSchema
        _id:
          type:String
    ,
      selector: 
        draft:false
      schema: new SimpleSchema
        _id:
          type:String
  ]


fs_collections= []

Meteor.startup ->
    fs_collections.push glob.SubmissionFiles


join.config.collection_list = -> 
  ret = Meteor.Collection.getAll().filter (col)-> not col.name.startsWith 'cfs'
  ret.push fs_collections
  return ret
join.config.collection_for_name = _.wrap join.config.collection_for_name, (orig_func,name)->
  if name instanceof FS.Collection
    return name
  else if _.isString name
    for col in fs_collections
      if col.name == name
        return col
    return orig_func.call this,name
  else
    return orig_func.call this,name

join.config.schemas_for_collection = _.wrap join.config.schemas_for_collection, (orig, col)->
  unless col?
    throw new Error "no collection supplied"
  console.log "returning schemas for col #{col._name}"
  if col instanceof Meteor.Collection
    return orig.call this, col
  else if col instanceof FS.Collection
    console.log 'returning fs_collection_schema_defs' #, fs_collection_schema_defs
    return fs_collection_schema_defs
join.config.schema_for_doc = _.wrap join.config.schema_for_doc , (orig ,collection,doc)->
  collection = join.config.collection_for_name collection
  if collection instanceof FS.Collection
    schemas = join.config.schemas_for_collection collection
     
    for schema in schemas
      if _.isEqual _.pick(doc , _.keys(schema.selector)) , schema.selector
        return schema.schema
    return
  else
    orig.call this, collection, doc



