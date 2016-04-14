do(tmpl=Template.submissionsCandidateEditPresentation)->
  helpers= {}
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom "_ss_base" 
  tmpl.inheritsHooksFrom '_ss_base'