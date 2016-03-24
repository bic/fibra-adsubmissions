do(tmpl=Template.submissionsCandidateEditCredits)->
  tmpl.inheritsHelpersFrom '_form_page_template_base'
  helpers = {}
  tmpl.instance_helpers helpers
  
    
do(tmpl=Template.horsey_test)->
  helpers=
    horsey_ctx:->
      debugger
      return this
    action:->
      (els, callbacks, changed) ->

        debugger
    
  Meteor.startup ->
    helpers.schemas= Schemas
    tmpl.helpers helpers
do(tmpl=Template.credits)->
  tmpl.inheritsHelpersFrom '_form_page_template_base'
