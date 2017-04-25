_= lodash
do(tmpl=Template.files_display)->
  file_ctx= (inst,data)->
    case_file_idx=1
    creative_file_idx=1
    return (file,idx)->
      if file.is_case_file
        title= "Case File #{case_file_idx}"
        case_file_idx++
      else
        title= "Creative File #{creative_file_idx}"
        creative_file_idx++
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
      unless this.data._id
        return
      data = Submissions.findOne(this.data._id)
      debugger
      ret= data.files?.map file_ctx(inst,data)
      
      return unless ret? and ret.length
      ret= ret.filter (file)-> file.file?.is_case_file
      
    other_files: (inst)->
      unless this.data._id
        return
      data = Submissions.findOne(this.data._id)
      debugger
      ret= data.files?.map file_ctx(inst, data)
      return unless ret? and ret.length
      ret= ret.filter (file)->(not file.file?.is_case_file)
      
    translation:(inst)->
      _.get @data, "#{@name}.translation"

  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base'
do(tmpl=Template.file_display)->
  helpers=
    file:(inst)->
      id= _.get @data, "#{@name}.file_id"

      unless id
        console.error "Cannot find file prop #{@name}.file_id for submission #{@data.id}"
        return
      ret= SubmissionFiles.findOne(id)
      return ret
    url: (inst)->
      ## See https://github.com/CollectionFS/Meteor-CollectionFS/issues/614
      ret = @url
        filename: encodeURIComponent(this.name())
      return ret
  tmpl.helpers helpers
  tmpl.events
    'click .fullscreen-on-click':(e,tmpl)->
      elm= e.currentTarget
      if (elm.requestFullscreen) 
        elm.requestFullscreen()
      else if (elm.msRequestFullscreen) 
        elm.msRequestFullscreen();               
      else if (elm.mozRequestFullScreen) 
        elm.mozRequestFullScreen();      
      else if (elm.webkitRequestFullscreen) 
        elm.webkitRequestFullscreen();       
      else 
        console.log("Fullscreen API is not supported");
       


