share.on_json_loaded ->
  merge_schema= {}
  for col_def in app_json.application.collections
    col= share.collection_for_name col_def.name
    schema = col.simpleSchema?()
    if schema
      schema= schema.schema()
      unless schema._id?
        merge_schema[col_def.name] =
          _id:
            type:String
            optional: true
        

  share.merge_schema merge_schema


