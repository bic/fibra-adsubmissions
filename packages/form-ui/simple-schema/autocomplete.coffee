
init_autocomplete = (json)->
  merge_schema = {}
  for col_def in json.collections
    col = share.collection_for_name(col_def.name)
    schema = col?.simpleSchema?()?.schema()
    if schema?
      for field_name, field_def of schema
        if field_def.join?
          foreign_collection = share.collection_for_name(field_def.join.collection)
          foreign_schema = foreign_collection.simpleSchema?()?.schema()
          unless foreign_schema
            console.error "could not find schema for collection #{field_def.join.collection}, referenced from #{col_def.name}.#{field_name}."
          else
            merge_schema[col_def.name]?={}
            label_field = _.findKey foreign_schema, (def)-> def?.input_spec?.label
            merge_schema[col_def.name][field_name]=
              autocomplete:
                type:'horsey'
                query: {}
                transform: do (label_field, field_name)-> 
                  if label_field?
                    label = foreign_schema[label_field].input_spec.label
                    unless _.isFunction label
                      label = (doc)->doc[label_field]
                    else
                      label = (doc)->doc._id
                  else
                    label= (doc)->doc[field_name]
                  (doc)->
                    txt= label(doc)
                    ret = 
                      _id:doc._id
                      text: txt
                      value: doc._id
                    return ret
                suggestions: do(schema,col,foreign_collection,field_name) -> 
                  (value, done)->
                    input_spec  = schema[field_name].input_spec
                    query = input_spec.autocomplete.query
                    if _.isFunction query
                      query= query(value)
                    cur =  foreign_collection.find query , 
                      transform: input_spec.autocomplete.transform
                    done  cur.fetch().filter (doc)->doc.text? and doc.value?
  share.merge_schema 'input_spec', merge_schema
share.on_json_loaded -> 
  init_autocomplete(app_json.application);

