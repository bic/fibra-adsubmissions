AutoForm.setDefaultTemplateForType('afArrayField', 'fibra');

do(tmpl=Template.afArrayField_fibra)->


  tmpl.inheritsHelpersFrom "afArrayField_bootstrap3" 
  tmpl.inheritsHooksFrom 'afArrayField_bootstrap3'
  tmpl.inheritsEventsFrom 'afArrayField_bootstrap3'
  helpers =
    show_field: (inst,name)->
      debugger
      fields = inst.fields.__selector()

      return fields.indexOf(name) > -1
    debug:(inst)->
      A= AutoForm
      debugger
    show_min_btn: (inst)->
      debugger
      if 'showRemove'  of inst.data.atts
        if inst.data.atts.showRemove == 'descendent'
          return false
        else
          return inst.data.atts.showRemove
      else
        return true
      debugger
      true
    show_min_btn_subfield:(inst)->
      if 'showRemove'  of inst.data.atts
        if inst.data.atts.showRemove == 'descendent'
          return false
      else
        return false
    explain_template: (inst)->
      debugger
      has_explain = false
      if @atts.explain_template and Template[@atts.explain_template]
        tmpl= Template[@atts.explain_template]
        has_explain = true
      else
        tmpl = Template.afTextExplain
      if @explain
        has_explain= true
      if has_explain
        return tmpl
      return
  tmpl.instance_helpers helpers
