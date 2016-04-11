

share.get_link_context= (elm)->
  inst = share.find_link_schema_template elm
  unless inst?
    return
  ret = 
    template : inst
    field_schema: inst.reactiveForms.schema
    field: inst.data.field
  if inst.reactiveForms.parentData?
    ret.link_schema=  inst.reactiveForms.parentData.schema
  if spec = ret.field_schema?.schema(ret.field).input_spec
    ret.input_spec= spec
  return ret
share.parent_form= (elm)->
  ret = false
  parents = share.find_field_template_parents elm
  if parents.length
    if parents[0].data?.form_picker
      form = null
      share.each_parent_template elm , (inst)-> 

        if inst.view.name.endsWith 'bs_form'
          form = view.templateInstance()
          return false # stop iteration
        else if inst.reactiveForms?.parentData?
          form = inst.reactiveForms.parentData.templateInstance
          return false
      if form 
        return form
    else
      return
  else
    return
do(tmpl= Template.bs_autocomplete)->
  get_reactive_form_ctx=(element)->
    # 
    view = Blaze.getView(element)
    while view?.parentView?
      if ret= view.templateInstance?()?.reactiveForms
        return ret
      view = view.parentView
    return 
  
  
  tmpl.onRendered ->
    warn = @data.warn_on_nonautocomplete_fields
    selector = @data.selector
    selector?='.reactive-element'
    
    @findAll(selector).forEach (elm)=>
      debugger
      view = 
      ctx = get_reactive_form_ctx elm
      if ctx?.schema?
        field_schema= ctx.schema
        field_def= ctx.schema.getDefinition(ctx.field)
        link_ctx= share.get_link_context elm
        if link_ctx?
          link_template = link_ctx.template
          #take autocomplete preferably from link definition
          autocomplete= link_ctx.input_spec?.autocomplete
        #otherwhise from field definition on the linked entity
        autocomplete?= field_def.input_spec?.autocomplete
        if autocomplete? 
          if _.isObject(autocomplete) and autocomplete?.type == 'horsey'
            horsey(elm, autocomplete)
          else
            console.warn "ignoring unknown schema for autocompletetion field #{ctx.field}, with autocomplete: #@autocomplete}"
        else if warn
          console.warn "schema for field #{ctx?.field} does not have an autocomplete field. current field def #{field_def}"
      else if warn
        console.warn "Could not find reactive element context for #{elm}. Is it registered with form:templates?"
  tmpl.events
    "horsey-selected": (e,tmpl)->
      debugger
      input_text = e.target.value
      ###
      ## horsey does not deliver the text, just the value, so
      ## rerun the suggestions to save the text instead of the value
      ###
      link_ctx= share.get_link_context e.target
      if _.isFunction (autocomplete=link_ctx?.input_spec?.autocomplete)?.suggestions
        picked_value = e.originalEvent.detail
        picked_text= ""
        autocomplete.suggestions "" ,  (list)->
          for suggestion in list
            if suggestion.value==picked_value and suggestion.text?
              picked_text = suggestion.text
              break
        if picked_text
          e.target.value = input_text.replace picked_value , picked_text
      if form = share.parent_form e.target
        form.id.set picked_value
      #TODO: this needs to be figured out from reactiveForms config
      $(e.target).trigger('keyup')
      debugger

    

ReactiveForms.createElement
  template: 'bs_autocomplete'