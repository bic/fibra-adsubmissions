_=lodash
do(tmpl= Template.evaluate_submission)->
  
  helpers=
    compile_ctx: (inst)->
      id= @id or Router.current().params.id
      data= Submissions.findOne(id)
      #if  @data 
      #  data=_.merge data, @data
      ret=
        data:data
        state:Session
      return ret
    sections:->
      Submissions.findOne(@_id)?.sections

  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 
do(tmpl= Template.review_display)->

  tmpl.inheritsHelpersFrom 'basics_display'
  tmpl.inheritsHooksFrom 'basics_display'
  tmpl.inheritsEventsFrom 'basics_display'