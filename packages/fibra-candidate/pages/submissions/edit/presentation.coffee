do(tmpl=Template.submissionsCandidateEditPresentation)->
  helpers = {}
  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers
