_= lodash
do(tmpl=Template.company_display)->
  helpers=
    have_company:(inst)->
      _.get(@data, @name)?
    title:(inst)->
      if name = _.get @data , "#{@name}.company"
        "#{name} - #{@title}"
      else
        "[name missing] - #{@title}"
    contacts:(inst)-> 
      ret= _.defaults {name:"#{@name}.contacts", is_list:true, schema:inst.schema},this
      return ret
      contacts = _.get @data , "#{@name}.contacts"
      unless contacts?
        return
      contacts.map (contact, idx)=>
        name: "#{@name}.contacts.#{idx}"
        data:@data
        schema: inst.schema
    contacts_name: -> "#{@name}.contacts"
    designated_contact:(inst)->
      name:"#{@name}.designated_contact"
      schema: inst.schema
      data:@data
  tmpl.instance_helpers helpers

  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 
do(tmpl=Template.production_display)->
  helpers={}
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base'
do(tmpl=Template.media_display)->
  helpers={}
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 
do(tmpl=Template.other_companies_display)->
  helpers=
    company_ctx:(inst)->
      @data.other_companies.map (comp, idx)=>
        ret={}
        if comp.role
          ret.title = comp.role
        else
          ret.title = "[Missing Company Role]"
        ret.name = "other_companies.#{idx}"
        ret.data=@data
        return ret

  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base' 