do(tmpl=Template.submissionsCandidateEditCredits)->
  helpers = {}
  Meteor.startup ->
    helpers.schemas= Schemas
    tmpl.instance_helpers helpers
  tmpl.onCreated ->
    @subscribe 'Contacts'
   
    
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
do(tmpl=Template.dependent_edit_test)->
  tmpl.instance_helpers
    action: ->
      (els, callbacks, changed, original_function)->
        @draft=true
        debugger
        original_function.call this, els, callbacks, changed
    schema_selector: 
      draft:true

do(tmpl= Template.people_role_list)->
  helpers = 
    role_field_name: -> "#{@field}.$.role"
    link_field_name: -> "#{@field}.$.contact_id"
    entry_number: -> @index+1
    show_remove: -> @count > @min
  tmpl.instance_helpers helpers