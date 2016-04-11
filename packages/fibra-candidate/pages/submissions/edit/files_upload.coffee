_= lodash
do(tmpl=Template.SubmissionsCandidateEditFilesUpload)->
  helpers=
    file: (inst)->
      SubmissionFiles.find()
    humanize_filesize:->
      filesize(@original.size)
    delete_button_template:->
      Blaze._globalHelpers.FS.DeleteButton
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_form_page_template_base'
  tmpl.events
    'file_uploaded.file_uploader .file_uploader_container.reactive_element' : (e,tmpl)->
      Tracker.afterFlush ->
        form_ui.parent_form_instance(e.currentTarget).reactiveForms.submit()
      
do(tmpl=Template.fs_deletebutton)->
  #some strange error occurs when doing +FS.DeleteButton
  tmpl.events
    "click .btn": (e,tmpl)->
      this.collection.remove(this._id)

do(tmpl= Template.file_management)->
  helpers=
    has_file:(inst)->
      parent_form = form_ui.parent_form_instance()
      path =  form_ui.data_path()
      val = _.get parent_form.data?.data , path
      debugger
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_form_page_template_base'

      