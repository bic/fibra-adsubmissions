
_= lodash

do(tmpl= Template.bs_switch)->
  
  tmpl.events
    "change input.reactive-element": (e,inst)->
      debugger
    "click":->
      debugger
    "switch-change":(e,inst)->
      debugger
    "switchChange.bootstrapSwitch":(e,inst)->
      debugger
    "fuck .reactive-element":(e,inst)->
      debugger


  # swich options are gathered from http://www.bootstrap-switch.org/options.html
  # using `$('table td:first-child').map((i,x)=>x.textContent)` in the console
  switch_options = [
    "state", 
    "size", 
    "animate", 
    "disabled", 
    "readonly", 
    "indeterminate", 
    "inverse", 
    "radioAllOff", 
    "onColor", 
    "offColor", 
    "onText", 
    "offText", 
    "labelText", 
    "handleWidth", 
    "labelWidth", 
    "baseClass", 
    "wrapperClass", 
    "onInit", 
    "onSwitchChange"]

    
  tmpl.onRendered ->
    @options= new ReactiveVar()
    ##todo use a Reactivedict and the options setters on the live instance()
    on_switch=(e,state)=>
      elm= @find('input.reactive-element')
      elm.checked= state
      $(elm).trigger 'change'


    @autorun (c)=>
      # this compiles the options
      debugger
      schema_options = share.schema_for_template_inst(this)?.input_spec?.switch
      data= Template.currentData()
      if schema_options and data
        options= _.extend {}, schema_options, _.pick data, switch_options
      else if schema_options?
        options= schema_options
      else if data?
        options =  _.pick data, switch_options
      else
        options= {}
      if options.onSwitchChange?
        options.onSwitchChange = _.wrap orig , ->
          on_switch.apply this,arguments
          orig.apply this,arguments
      else
        options.onSwitchChange  = on_switch    
      @options.set options
    find_dumb_bootstrap_switch = (inst)->
      set = $(inst.firstNode).nextUntil(inst.lastNode).addBack()
      ret = set.filter('.buggy-bootstrap-switch-dumb-dummy')
      if ret.length
        return ret
      else 
        return set.find('.buggy-bootstrap-switch-dumb-dummy')
    @autorun (c)=>
      #this instantiates bootstrapSwitch
      elm = find_dumb_bootstrap_switch this
      unless elm
        debugger
      console.log "before switch", @find('input')
      unless c.firstRun
        state= elm.bootstrapSwitch('state') 
        elm.bootstrapSwitch('destroy')
          
      if state?
        new_options=
          state:state
      else
        new_options={}
      new_options = _.defaults new_options , @options.get()
      elm.bootstrapSwitch new_options
      console.log "after switch", @find('input')
    @autorun =>
      $elm= find_dumb_bootstrap_switch this
      unless $elm[0]
        debugger
      # the value autorun
      state = @reactiveForms.value.get()
      currentState = $elm.bootstrapSwitch('state')
      unless currentState == state
        $elm.bootstrapSwitch('state', currentState, true)


  reactive_forms_options=
    template: 'bs_switch'
    validationValue:(element,clean, template)->
      debugger
      return  $(element).prop('checked')
    validationEvent: 'change'
  ReactiveForms.createElement reactive_forms_options
 
  # add the value_ref handling part
  share.install_value_dependency_handler  tmpl

 