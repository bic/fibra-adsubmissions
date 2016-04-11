_= lodash
do(tmpl=Template.submissionsCandidateEditPreview)->
  helpers = {}

  tmpl.inheritsHelpersFrom '_form_page_template_base'
  tmpl.instance_helpers helpers