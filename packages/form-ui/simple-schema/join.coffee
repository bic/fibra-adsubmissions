_ = lodash

SimpleSchema.extendOptions
  join: Match.Optional Match.OneOf String, 
    "collection": String
    "key": Match.Optional String

init_joins = (json)->
  merge_schema= {}
  for col_def in json.collections
    for field_def in col_def.fields
      if field_def.join_collection
        merge_schema[col_def.name]?={}
        merge_schema[col_def.name][field_def.name] = 
          collection: field_def.join_collection
  debugger
  share.merge_schema 'join', merge_schema
share.on_json_loaded ->
  init_joins app_json.application
