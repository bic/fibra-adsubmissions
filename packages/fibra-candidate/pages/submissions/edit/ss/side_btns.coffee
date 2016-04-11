

has_id = new ReactiveVar()
Tracker.autorun ->
   params= Router.current()?.getParams()
   has_id.set params?.id?.length == 17
disable_without_id = (tmpl)->
  tmpl.onRendered ->
    @autorun =>
      $(@firstNode).parents('.side-bar-item').toggle(has_id.get())
add_valid_helper= (tmpl, validation_step)->
  tmpl.instance_helpers 
    valid: ->
      fields = share.fields[validation_step]
      unless fields
        return
      field_list= fields.split ','
      s= Submissions.simpleSchema({draft:false})
      for field in field_list
        #see https://github.com/aldeed/meteor-simple-schema/issues/284
        if s.schema()[field+".$"]
          field_list.push field+'.$'

      
      picked_s= s.pick( field_list)
      doc =  Submissions.findOne(Router.current()?.params?.id)
      unless doc?
        return
      picked_s.clean(doc)
      try
        picked_s.validate doc
        #throws otherwhise
        return true 
      catch e
        debugger
        return false

do(tmpl=Template.basics_btn)->
  disable_without_id(tmpl, 'basics')
  add_valid_helper(tmpl, 'basics')
do(tmpl=Template.credits_btn)->
  add_valid_helper(tmpl, 'credits')
  disable_without_id(tmpl, 'credits')
do(tmpl=Template.production_btn)->
  add_valid_helper(tmpl, 'production')
  disable_without_id(tmpl, 'production')
do(tmpl=Template.media_btn)->
  add_valid_helper(tmpl, 'media')
  disable_without_id(tmpl, 'media')
do(tmpl=Template.other_contributors_btn)->
  add_valid_helper(tmpl, 'other_contributors_btn')
  disable_without_id(tmpl, 'other_contributors_btn')
do(tmpl=Template.case_presentation_btn)->
  add_valid_helper(tmpl, 'case_presentation_btn')
  disable_without_id(tmpl, 'case_presentation_btn')
do(tmpl=Template.files_upload_btn)->
  add_valid_helper(tmpl, 'files_upload_btn')
  disable_without_id(tmpl, 'files_upload_btn')
do(tmpl=Template.preview_btn)->
  disable_without_id(tmpl, 'preview_btn')
