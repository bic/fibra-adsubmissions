do(tmpl=Template.basics_display)->

    
  helpers=
    
    debug:(inst)->
      debugger
    plus_one:(inst,arg)->
      arg+1
    field_name:(inst,field)->
      schema=inst.schema.schema(field)
      if schema.label
        return schema.label
      else
        return field
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 
