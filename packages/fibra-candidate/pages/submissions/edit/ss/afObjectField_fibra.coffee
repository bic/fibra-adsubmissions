AutoForm.setDefaultTemplateForType('afObjectField', 'fibra');
do(tmpl=Template.afObjectField_fibra)->
  helpers= 
    debug: (inst)->
      A= AutoForm
      debugger
    explain_template: (inst)->
      debugger
      has_explain = false
      if @explain_template and Template[explain_template]
        tmpl= Template[explain_template]
        has_explain = true
      else
        tmpl = Template.afTextExplain
      if @explain
        has_explain= true
      if has_explain
        return tmpl
      return
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom "afObjectField_bootstrap3" 
  tmpl.inheritsHooksFrom 'afObjectField_bootstrap3'
do(tmpl=Template.afObjectField_fibra_table)->
  helpers= 
    debug: (inst)->
      A= AutoForm
      debugger
    tableClass: (inst)->
      return @tableClass || ""
    visible_field_count:-> "1"
    hide_label:->
      @label==false
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom "afObjectField_fibra" 
  tmpl.inheritsHooksFrom 'afObjectField_fibra'
do(tmpl=Template.afObjectField_fibra_naked)->

  tmpl.inheritsHelpersFrom "afObjectField_fibra" 
  tmpl.inheritsHooksFrom 'afObjectField_fibra'