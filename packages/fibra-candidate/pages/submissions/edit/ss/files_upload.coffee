_=lodash
do(tmpl= Template.SubmissionsCandidateEditFilesUpload)->
  helpers= {}
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom "_ss_base" 
  tmpl.inheritsHooksFrom '_ss_base'