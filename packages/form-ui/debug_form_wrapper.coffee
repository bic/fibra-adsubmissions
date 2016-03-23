do (tmpl=Template.debug_form_wrapper)=>
  instrument_form= (inst)->
    #inst is a form instance
    form_tmpl= Blaze.findTemplateInstances('bs_form')[0]
    orig_func = form_tmpl.reactiveForms.setFormDataField
    self=this
    form_tmpl.reactiveForms.setFormDataField = ->
      ret = orig_func.apply this,arguments
      self.value_change_dep.changed()
      return ret
    @autorun (c)=>
      @value_change_dep.depend()
      @value = form_tmpl.reactiveForms.validatedValues

  helpers =
    form: (inst)->
      inst.form.get()
    debug_json: (inst)->
      inst.value_change_dep.depend()
      JSON.stringify inst.value, null, 2
  tmpl.instance_helpers helpers
  tmpl.onCreated ->
    @form = new ReactiveVar()
    @value_change_dep = new Tracker.Dependency()
  tmpl.onRendered ->
    # Search for first form direcly beneath this (forms beneath other forms are ignored)
    debugger
    instances = Blaze.findTemplateInstances('bs_form');
    found = false
    for inst in instances
      view = inst.view.parentView 
      while view
        picked_inst= view.templateInstance?()
        if view == this.view
          found= true
          break 
        else if view.name == 'Template.bs_form'
          # was actually a subform, so ignore that
          break
        view = view.originalParentView or view.parentView
      if found
        instrument_form.call this, inst
        @form.set picked_inst
        break