do(tmpl=Template.basics_display)->

    
  helpers=
    
    debug:(inst)->
      debugger
    plus_one:(inst,arg)->
      arg+1
    
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 
