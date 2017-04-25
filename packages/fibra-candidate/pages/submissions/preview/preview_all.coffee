_=lodash
do(tmpl= Template.preview_all)->
  helpers=
    compile_ctx: (inst)->
      id= @id or Router.current().params.id
      data= Submissions.findOne(id)

      if  @data 
        data=_.merge data, @data
      debugger
      ret=
        data:data
      return ret
    is_admin:(inst)->
      Meteor.users.isAdmin(Meteor.userId())
    
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 
