###
create a new schema with all properties being optional
###
share.make_schema_fields_optional= (schema)->
  _.mapValues schema , (val,key)->
    if 0 > key.indexOf '.'
      #only make top level keys optional
      val.optional=true
    return val;

share.on_json_loaded ->
  draft_def = 
    type:Boolean
  for col_def in app_json.application.collections
    col= share.collection_for_name col_def.name
    schema = col.simpleSchema?()
    if schema
      schema= schema.schema()
      draft_schema = share.make_schema_fields_optional _.cloneDeep schema
      schema.draft = draft_def
      draft_schema.draft = draft_def
      col.attachSchema schema ,
        replace:true
        selector:
          draft:false
      col.attachSchema draft_schema,
        selector:
          draft:true





