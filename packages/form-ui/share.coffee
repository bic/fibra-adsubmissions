_=lodash

class share.ReactiveCallbackProvider 
  constructor:->
    @dep = new Tracker.Dependency()
    @_cb_list= []
  on: (fn)=>
    @_cb_list.push fn
    dep= @dep
    dep.changed()
    ret=
      remove:=>
        index = @_cb_list.indexOf fn
        @_cb_list.splice index,1
        dep.changed()
      after:(fn)=>
        #adds another callback just after this one
        index = @_cb_list.indexOf fn
        @_cb_list.splice index+1,0, fn
        dep.changed()
      before:(fn)=>
        #adds another callback just before this one
        index = @_success_cb.indexOf fn
        @_cb_list.splice index,0, fn
        dep.changed()
  forEach: (fn)->
    @dep.depend()
    @_cb_list.forEach fn
  
  ###
    has() -> true if any callbacks are installed
    has(fn)-> true if the function fn has been registered
  ### 

  has:()->
    @dep.depend()
    if arguments.length
      return @_cb_list.indexOf(arguments[0]) > -1
    else
      return @_cb_list.length > 0
  count:()->
    @dep.depend()
    @_cb_list.length
_.extend share,
  install_callback_provider:(name, object)->
    unless object?
      object= this
    handler = new share.ReactiveCallbackProvider

    func_name= "on_#{name}"
    if object[func_name]?
      form_ui.except "function with name #{func_name} already exists on #{object.toString()}"
    
    object[func_name] = (fn)->
      return handler.on(fn)
    object[func_name].handler= handler
  schema_for_template_inst: (inst)->
    react = inst.reactiveForms
    return unless react?
    schema = react.schema
    return unless schema?
    if react.field?
      #inst is field
      return schema.schema()[react.field]
    else
      #inst is form

      return schema.schema()
  ##
  ## this installs a handler for a `value_ref` template parameter
  ## the parameter will be updated whenever the data changes and must be a `reactive variable`
  ## @param tmpl the template to install the value_ref data option handling onto
  ## this shall be called after ReactiveForms registration, otherwhise the reactiveForms handlers are not installes
  ## also this is only for ReactiveElements
  
  install_value_dependency_handler: (tmpl )->
    tmpl.onCreated ->
      forwarder = null
      unless @reactiveForms.value?
        form_ui.throw "no reactiveForms detected on this Template. Has this Template been registered with ReactiveForms.createElement? and has the registration occured before calling install_value_dependency_handler?"
      @autorun (c)=>
        data= Template.currentData()
        if data.value_ref? 
          if data.value_ref instanceof ReactiveVar
            @value = data.value
            forwarder?.stop()
            Tracker.nonreactive =>
              forwarder= Tracker.autorun =>
                data.value_ref.set @reactiveForms.value.get()
            c.onStop ->
              forwarder.stop()
          else
            forum_ui.except( "The value_ref option must be a ReactiveVar")
      
      


      