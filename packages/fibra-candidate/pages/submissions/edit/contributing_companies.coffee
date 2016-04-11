#do(tmpl=Template.submissionsCandidateEditProduction)->


do (tmpl= Template.submissionsCandidateEditOtherContributors)->
  helpers=
    has_companies : ->
      @data?.other_companies?.length > 0
    show_new_company: (inst)->
      inst.show_new_company.get()
    company_role_name: (inst)->
      value_refs = inst.value_refs_for_index @index
      name= value_refs.name.get()
      role= value_refs.role.get()
      ret = name
      unless ret? and ret.length
        ret= "New Company"
      if role? and role.length
        ret = "#{role} - #{ret}"
      return ret
    value_refs:(inst)->
      _.extend this, 
        value_refs: inst.value_refs_for_index(@index)
  tmpl.onCreated ->
    @value_refs=[]
    @value_refs_for_index =(idx)=>
      while @value_refs.length <= idx        
        @value_refs.push
          role: new ReactiveVar()
          name: new ReactiveVar()
      return @value_refs[idx]
  tmpl.inheritsHelpersFrom '_form_page_template_base'
  tmpl.instance_helpers helpers
do(tmpl = Template.submissionsCandidateEditProduction)->
  helpers={}
  Meteor.startup ->
    tmpl.inheritsHelpersFrom '_form_page_template_base'
    tmpl.instance_helpers helpers
do(tmpl = Template.submissionsCandidateEditMedia)->
  tmpl.onRendered ->
    @find('.panel-group')
  helpers={}
  
  tmpl.inheritsHelpersFrom '_form_page_template_base'
  tmpl.instance_helpers helpers
  

do(tmpl= Template.contributing_company) ->
  helpers = 
    action:->
      (els, callbacks, changed) ->
        debugger
    company_id_field_name: (inst)-> "#{inst.data.field}.company_id"
    team_members_field_name: (inst)->"#{inst.data.field}.contacts"
    designated_contact:(inst)->"#{inst.data.field}.designated_contact_id"
    role_field_name:(inst)->"#{inst.data.field}.role"
  tmpl.inheritsHelpersFrom '_form_page_template_base'
  tmpl.instance_helpers helpers
