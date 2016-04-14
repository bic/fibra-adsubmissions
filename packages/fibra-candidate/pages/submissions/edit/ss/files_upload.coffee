_=lodash
do(tmpl= Template.SubmissionsCandidateEditFilesUpload)->
  helpers= {}

  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom "_ss_base" 
  tmpl.inheritsHooksFrom '_ss_base'
do(tmpl= Template["file-upload-explain"])->
  tmpl.helpers
    is_case_file:(inst)->
      AutoForm.getFieldValue(this.name+".is_case_file")