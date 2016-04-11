do(tmpl= Template.people_role_list)->
  helpers = 
    role_field_name: -> 
      unless @field
        debugger
      "#{@field}.role"
    link_field_name: -> "#{@field}.contact_id"
    entry_number: -> @index+1
    show_remove: -> @count > @min
  tmpl.instance_helpers helpers