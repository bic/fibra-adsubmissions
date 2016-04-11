_=lodash
do(tmpl= Template.submissionsCandidateEditCredits)->
  helpers= {}
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom("_ss_base")
  tmpl.inheritsHooksFrom '_ss_base'