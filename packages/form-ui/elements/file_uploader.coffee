do(tmpl=Template.file_uploader)->
  tmpl.onRendered ->
    $("input[type='file']").fileinput();

  tmpl.events
    'change #field-submission_file_id': (e, t) ->
      e.preventDefault()
      fileInput = $(e.currentTarget)
      dataField = fileInput.attr('data-field')
      hiddenInput = fileInput.closest('form').find('input[name=\'' + dataField + '\']')
      FS.Utility.eachFile event, (file) ->
        SubmissionFiles.insert file, (err, fileObj) ->
          if err
            console.log err
          else
            hiddenInput.val fileObj._id