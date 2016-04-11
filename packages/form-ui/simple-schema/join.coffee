_ = lodash

SimpleSchema.extendOptions
  join: Match.Optional Match.OneOf String, 
    "collection": String
    "key": Match.Optional String
    "deny_insert": Match.Optional Boolean

init_joins = (json)->
  merge_schema= {}
  for col_def in json.collections
    for field_def in col_def.fields
      if field_def.join?
        # if we have a join field in the definition
        merge_schema[col_def.name]?={}
        merge_schema[col_def.name][field_def.name] = field_def.join
      else if field_def.join_collection
        # if we have a join_collection from original meteor-kitchen json 
        merge_schema[col_def.name]?={}
        merge_schema[col_def.name][field_def.name] = 
          collection: field_def.join_collection

  share.merge_schema 'join', merge_schema
share.on_json_loaded ->
  init_joins app_json.application

  share.merge_schema 'join',
      submissions:
        'section_ids.$':
          deny_insert:true