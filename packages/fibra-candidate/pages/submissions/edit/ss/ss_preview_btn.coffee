do(tmpl=Template.ss_preview_btn)->
  tmpl.events
    "click .do-preview":(e,tmpl)->
      view = Blaze.getView($('form')[0])
      while view
        if view.name == 'Template.autoForm' or view.name == 'Template.quickForm'
          break
        view = view.originalParentView or view.parentView
      debugger
      unless view?
        throw new Error "No Form found on Page"
      form = view.templateInstance()
      data= AutoForm.getFormValues( form.data.id).insertDoc

      #Modal.show 'basics_display'
      Modal.show 'preview_modal' , 
        template: 'preview_all'
        data: 
          data: data
      e.preventDefault();