_= lodash
do(tmpl=Template.files_display)->
  file_ctx= (inst,data)->
    return (file,idx)->
      if file.is_case_file
        title= "Case File #{idx+1}"
      else
        title= "Creative File #{idx+1}"
      if file.name?
        title = "#{title} - #{file.name}"
      else
        title = "#{title} - [Missing Title]"

      ret=
        data:data
        title:title
        name: "files.#{idx}"
        schema: inst.schema
        file:file


  helpers=
    case_files:(inst)->
      debugger
      ret= @data.files.map file_ctx(inst,@data)
      ret= ret.filter (file)-> file.file.is_case_file
      
    other_files: (inst)->
      ret= @data.files.map file_ctx(inst, @data)
      ret= ret.filter (file)->(not file.file.is_case_file)
      
    translation:(inst)->
      debugger
      _.get @data, "#{@name}.translation"

  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base'
do(tmpl=Template.file_display)->
  helpers=
    file:(inst)->
      debugger
      id= _.get @data, "#{@name}.file_id"
      ret= SubmissionFiles.findOne(id)
      return ret
  tmpl.helpers helpers


