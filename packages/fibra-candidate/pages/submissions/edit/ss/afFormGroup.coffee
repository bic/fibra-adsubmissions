do(tmpl=Template.afFormGroup_fibra_inline)->
  helpers=
    classes: (inst)->
      ret = []
      if Blaze._globalHelpers.afFieldIsInvalid.call this, Blaze._globalHelpers.afFieldIsInvalid.call this, {hash: {name:this.name}}
        ret.push "has-errors"
      if @afFormGroupClass
        ret.push  @afFormGroupClass
      debugger
      return ret.join ' ' 
    show_remove_btn:(inst)->
      atts = AutoForm.Utility.getComponentContext(inst.data, 'afFormGroup')?.atts
      if atts?.showRemoveBtn
        return true
      return false
  tmpl.events
    'click .autoform-remove-item':->
      parent_array = Blaze.getView('Template.afArrayField')
      if parent_array
        debugger
      debugger
      return true
  tmpl.instance_helpers helpers
  tmpl.inheritsEventsFrom 'afFormGroup_bootstrap3'
  tmpl.inheritsHooksFrom 'afFormGroup_bootstrap3'
  tmpl.inheritsHelpersFrom 'afFormGroup_bootstrap3'
