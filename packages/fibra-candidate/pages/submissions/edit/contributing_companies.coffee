#do(tmpl=Template.submissionsCandidateEditProduction)->


do (tmpl= Template.submissionsCandidateEditOtherContributors)->
  helpers=
    has_companies = ->
      data.other_companies?.length > 0

  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers
do(tmpl = Template.submissionsCandidateEditProduction)->
  helpers={}
  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers
do(tmpl = Template.submissionsCandidateEditMedia)->
  helpers={}
  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers


do(tmpl= Template.contributing_companies) ->
  helpers = 
    action:->
      (els, callbacks, changed) ->
        debugger
    company_id_field_name: (inst)-> "#{inst.data.type}.company_id"
    team_members_field_name: (inst)->"#{inst.data.type}.contacts"
    designated_contact:(inst)->"#{inst.data.type}.designated_contact_id"
  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers
