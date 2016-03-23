do(tmpl=Template.submissionsCandidateEditBasics)->
  helpers = 
    action:->
      (els, callbacks, changed) ->
        debugger
  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers
