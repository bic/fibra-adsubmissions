do(tmpl=Template.SubmissionsCandidateEditFilesUpload)->
  helpers=
    file: (inst)->
      SubmissionFiles.find()
    humanize_filesize:->
      filesize(@original.size)
    delete_button_template:->
      debugger
      Blaze._globalHelpers.FS.DeleteButton
  tmpl.instance_helpers helpers
do(tmpl=Template.fs_deletebutton)->
  #some strange error occurs when doing +FS.DeleteButton
  tmpl.events
    "click .btn": (e,tmpl)->
      this.collection.remove(this._id)
      