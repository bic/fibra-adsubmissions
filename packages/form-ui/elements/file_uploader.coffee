do(tmpl=Template.file_uploader)->
  helpers= 
    show_upload:(inst)-> not inst.file.get()?
    hide_upload:(inst)-> inst.file.get()? and 'hide' or ''
    collection: (inst)->
      inst.reactiveForms.parentData.templateInstance.collection
    id:(inst)->
      inst.reactiveForms.parentData.templateInstance.id.get()  
    file:(inst)->
      file = inst.file.get()
      unless file?
        return
      ## the search is for reactivity
      debugger
      return share.collection_for_name(file.collectionName).findOne file._id
  tmpl.instance_helpers helpers
  tmpl.onRendered ->
    $("input[type='file']").fileinput
      showPreview:false

  tmpl.events
    'change input.file_uploader': (event, t) ->
      debugger
      event.preventDefault()
      fileInput = $(event.currentTarget)
      dataField = fileInput.attr('data-field')
      #hiddenInput = fileInput.closest('form').find('input[name=\'' + dataField + '\']')
      hiddenInput = $(t.find('.reactive-element'))
      form= t.reactiveForms.parentData.templateInstance
      FS.Utility.eachFile event, (file) ->
        file = new FS.File(file);
        file.metadata?={}
        file.metadata.owner_account= Meteor.userId()
        SubmissionFiles.insert file, (err, fileObj) ->
          if err
            console.log err
          else
            #hiddenInput.val fileObj._id
            form.id.set fileObj._id
            t.file.set file
            hiddenInput.trigger('file_uploaded.file_uploader')
  tmpl.onCreated ->
    @file=new ReactiveVar()
    @autorun =>
      form = form_ui.parent_form_instance(@view)
      id = form.id.get()
      unless id? and id !='new'
        return 
      col= share.collection_for_name form.data.collection
      @file.set col.findOne(id)
    @autorun =>
      data= Template.currentData()
      @data?=data= {}
      if @data.field? and @data.field!="_id"
        form_ui.except("file_uploader does not support any other field than _id on a FS.Collection. Use Link!")
      @data.field= "_id"

  ReactiveForms.createElement
    template: 'file_uploader'
    validationEvent: 'file_uploaded.file_uploader'
    validationValue: (el,clean,inst)->
      debugger
      inst.file.get()?._id
  # Todo when templates:forms starts using onCreated
  tmpl.onCreated tmpl.created
  delete tmpl.created
  

