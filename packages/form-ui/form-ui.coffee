
_= lodash 
glob= this
callback_id= new Meteor.EnvironmentVariable()

Template.registerHelpers
  
  debug_context :->
    debugger
  same_ctx:(args...,kwargs)->
    if args.length
      console?.warn "same_ctx: ignored unnamed args: #{args.join " "}, just adding #{JSON.stringify kwargs?.hash } to context!"
    return _.extend {},this,kwargs?.hash
  remove_from_ctx: (args..., kwargs)->
    if _.keys(kwargs?.hash).length
      console?.warn "remove_from_ctx: ignoring kwargs #{JSON.stringify kwargs?.hash }, just removing from context #{args.join ' '}"
    #console.log ("remove_from_ctx: removing #{JSON.stringify _.pick(this,args)} from context") 
    return _.omit this, args
  repeat: (arg..., kwargs)->
      if kwargs?.hash? and _.keys(kwargs.hash).length
        if arg.length 
          console?.warn "repeat helper:Ignoring argument #{arg[0]} in favor of named arguments #{JSON.stringify kwargs.hash}"
        arg= kwargs.hash
      unless arg? or (_.isArray(arg) and arg.length > 0)
        console?.warn "repeat helper: called without an argument. assuming 1"
        return [this]
      if _.isArray(arg)
        arg= 
          min:arg[0]
          max: if arg[2]? then arg[2] else arg[0]
          count: if arg[1]? then  arg[1] else arg[0]
      if _.isNumber(arg) or min= Number.parseInt(arg)
        arg = 
          min:arg
          max:arg
          count:arg
          
      if arg.count?
        arg.min?= arg.count
        arg.max?= arg.count
      ret= [] 
      if arg.min < arg.count
        may_add= true
      if arg.max > arg.count
        may_remove= true
      if arg.count == 0 
        return []
      for i in [0..arg.count-1]
        ctx= _.extend {},arg, this, 
          index:i
          is_required: i>arg.min-1, 
          is_last: i== (arg.min < arg.max) and(arg.max-1)
        ret.push ctx
      return  ret

do( tmpl=Template.form_ui_input_template)->
  tmpl.helpers 
    helper: ->
      #debugger
 

_.extend share,
  dot_setter: (obj, key, value) ->
    if typeof key == 'string'
      index obj, key.split('.'), value
    else if key.length == 1 and value != undefined
      obj[key[0]] = value
    else if key.length == 0
      obj
    else
      index obj[key[0]], key.slice(1), value
  
  find_parent_template: (elm, depth_or_pred, parent_limit)->
    if _.isFunction depth_or_pred
      test= depth_or_pred
      parent_limit?= Infinity
    else if _.isNumber depth_or_pred
      parent_limit= depth_or_pred
    view = Blaze.getView(elm)
    i= 0
    while view
      if _.isFunction view.templateInstance
        template = view.templateInstance()
        if test?
          return template if test template
        else if i == parent_limit-1
          return template
        i++
      view = view.originalParentView or view.parentView
    #found no template
    return 
  each_parent_view: (elm,fn)->
    view = Blaze.getView elm
    while view      
      if  false == fn(view)
        return
      if view.originalParentView?
        view= view.originalParentView
      else
        view= view.parentView
    return
  each_parent_template: (elm,fn)->
    share.each_parent_view elm, (view)->
      if view.templateInstance?
        if false == fn(view.templateInstance())
          return false
  find_field_template_parents:(elm)->
    ret = []
    share.each_parent_template elm, (inst)->
      if (inst.reactiveForms and inst.data.field)
        ret.push inst
    return ret
  find_link_schema_template: (elm) ->
    view = Blaze.getView(elm) 
    ret= null
    share.each_parent_template elm ,(inst)->
      if inst.link_schema?
        ret= inst
        return false # abort iteration
    if ret?
      return ret
    else
      return
  find_link_schema : (elm)->
    link_template= share.find_link_schema_template(elm)
    return link_template?.reactiveForms.schema?.getDefinition  link_template?.reactiveForms.field
  get_helper: get_helper= (name) ->
    Template.instance()?.view.template.__helpers.get(name)
  eval_helper:(name)->
    Template.instance()?.view.template.__helpers.get(name)?()
  general_form_helpers:
    show_add_btn:->
      if @show_add_btn? && not @show_add_btn
        return

      @max? and @count < @max and @index == @count-1
    show_remove_btn:->

      if @show_remove_btn? && not @show_remove_btn
        return
      else if @min? and @count? and @index? 
        return @count >@min
      else
        return @show_remove_btn




do(tmpl=Template.bs_input)->
  helpers= 
    classes:(arg)->
      arg= arg.hash
      if arg.changed
        if arg.valid
          return "has-success"
        else
          return "has-error"
      return
    

    form_control_attributes:->
      #debugger
      form= Template.instance().reactiveForm
      schema = get_helper('schema')?()
      ret={}
      if schema?
        s = new share.schema.field(schema)
        

        if @placeholder
          placeholder=@placeholder
        else
          placeholder= s.placeholder()  
        if @crunch_label_with_placeholder
          placeholder ?=""
          name= schema.label or @field
          if schema.label
            if placeholder?
              placeholder= "#{schema.label} - #{placeholder}"
            else
              placeholder= scheme.label
        if placeholder?
          ret.placeholder = placeholder
        wordspec = []
        if s.min_words()
          wordspec.push "less than #{schema.minWordCount}"
        if s.max_words()
          wordspec.push "more than #{schema.maxWordCount}"
        if s.choices()
          wordspec.push "Pick from below"
          if s.has_custom_choice()
            worspec[worspec.length-1]+= " or type your own"
        if wordspec.length
          if ret.placeholder
            ret.placeholder += "(#{wordspec.join(", ")}))"
          else
            ret.placeholder = wordspec.join(", ")
      #debugger
      if value= share.eval_helper 'value'
        ret.value= value
      unless _.keys(ret).length
        return

      return ret
    label_classes:->
      #option
      if @crunch_label_with_placeholder
        return 'sr-only'
  _.extend helpers, share.general_form_helpers
  tmpl.helpers helpers
do(tmpl=Template.bs_form)->
  #dbg_id=0
  ReactiveForms.createFormBlock
    template: 'bs_form'
    submitType: 'normal'

  tmpl.onCreated ->
    #@dbg_id=dbg_id++
    #@autorun =>
    #  console.log "form #{@dbg_id}'s data: ",Template.currentData()
    
    if @data?.collection?
      if _.isString collection= @data.collection 
        collection = share.collection_for_name @data.collection
        unless collection
          form_ui.except "Could not search for id: No collection #{@data.collection} founf!" 
      if @data.schema_selector
        @schema_selector= @data.schema_selector  
      try
        unless (schema= @data?.schema or collection?.simpleSchema?(@data.schema_selector))
          console.error "bs_form: collection = #{collection}. Did not find any schema"
      catch e
        form_ui.except( "You must supply a schema with schema_selector=<sel_field> when using Collection2 with multiple schemas and editing new objects!", e)
      
        
      #if @data.data 
      #  form_ui.err "bs_form: both data and id have been supplied. ignoring id"
      if true
        if @data.id instanceof ReactiveVar
          @id=@data.id
        else
          @id=new ReactiveVar(@data.id)
        
        # this happend if eiher no id has been supplied or a non-reactiveVar id was supplied
       
        parent_with= Blaze.getView ('with')
        @autorun (c)=> 
          ###
            TODO: might want to push this to rendered and only invalidate on a cursor with fields within the view.
            This, however must be supported by lists which might be empty (no reactiveElements) but still
            create reactiveElements after the initial rendered.
          ###
          ###
            This invalidates on any data change
            an id change would trigger whe query, while findOne makes sure it also depends on
            any fields changed 
          ###
          ###
            TODO: what happens if non-first-level fields change in the query? 
          ###
          @data.data = collection.findOne(id= @id.get())
          if id and id != "new" and not @data.data
            #debugger
            form_ui.err "could not find any object with id #{id} in collection: #{collection._name}", collection
          unless c.firstRun
            #On the first run the templates:forms initializer has not run yet, so no reason to invalidate parent 'with'
            parent_with.dataVar.dep.changed()

      if schema && not @data.schema
        @data.schema= schema # schema grab from Collection2 collection
      inst = this
      if collection




        action= (elms, callbacks, changed)->
          
          #console.log "action called call_ctx: #{callback_id.get()} on form (ID:#{inst.reactiveForms.ID}):", inst, "with context:", this  
        


          
          
          
  

          ###
          This creates a circular call from within submit of parentForm
          ###
          # reactiveFormsArray= elms.map (elm)->share.find_parent_template elm, (tmpl)->tmpl.reactiveForms
          # formDatas= _.uniq(reactiveFormsArray.map((x)->x.reactiveForms.parentData? and  x.reactiveForms.parentData or x.reactiveForms),(x)->x.ID)
          #formDatas.reverse().forEach (formData)=> 
          #  if formData.ID != inst.reactiveForms.ID and formData.changed.get()   
          #    #this is a subform which has been changed
          #    formData.submit()
          
          #now merge in the selector if it's not supplied by the document
          if inst.data.schema_selector
            doc = _.extend {}, inst.data.schema_selector , this
          else
            doc= this
          id = inst.id?.get()
          if id? and id != "new"
            if callbacks?
              #only define callback if no user action was supplied
              cb=(error,id)->
                #debugger
                if error?
                  #console.error "DONECB: error updating(ID:#{inst.reactiveForms.ID}):", error, inst
                  callbacks.failed(error)

                else
                  #console.log "DONECB: success updating (affected #{id})(ID:#{inst.reactiveForms.ID}):", inst
                  callbacks.success("Entry in #{inst.data?.collection} updated sucessfully!")
            if inst.data.no_db_operations
              #console.log "update suppressed on form (ID:#{inst.reactiveForms.ID}):", inst, "with context:", this
              cb undefined,1 
            else
              #console.log "update called on form (ID:#{inst.reactiveForms.ID}):", inst, "with context:", this
              collection.update id, {$set: doc}, cb
          else
            if callbacks?
              #only define callback if argument is present was supplied
              cb =(error,id)->
                
                if error?
                  #console.log( "DONECB: success updating (affected #{id})(ID:#{inst.reactiveForms.ID}):", inst)
                  callbacks.failed(error)
                else
                  
                  inst.id.set id
                  #console.log("DONECB: New #{inst.data?.collection} entry added sucessfully!((ID:#{inst.reactiveForms.ID})")
                  callbacks.success("New #{inst.data?.collection} entry added sucessfully!(ID:#{inst.reactiveForms.ID})")
            
            if inst.data.no_db_operations
              #console.log "insert suppressed on form (ID:#{inst.reactiveForms.ID}):", inst, "with context:", this
              cb(undefined,1);
            else
              inst.id.set collection.insert doc , cb
              #console.log "insert (insert_id: #{inst.id.curValue}) called on form (ID:#{inst.reactiveForms.ID}):", inst, "with context:", this
        action= _.wrap action  , ( old_action, elms, callbacks, changed)->
          #console.log "action wrapper called call_ctx: #{callback_id.get()} my id : ID:#{inst.reactiveForms.ID} "
          if glob.dbg_form == inst.reactiveForms.ID
            debugger
          if inst.on_before_action.handler.has()
            # we have before_action callbacks
            success= null
            success_msg= []
            failed_msg= []
            cb_count= inst.on_before_action.handler.count()
            
            finished= ()=>
              cb_count--
              #console.log("finished called, countdown: #{cb_count}, form: #{inst.reactiveForms.ID}", inst)
              #debugger
              if cb_count == 0
                if success
                  callbacks.success = _.wrap callbacks.success, (orig_handler, new_msg)->
                    success_msg.push new_msg
                    return orig_handler.call this, success_msg.join "\n"
                else
                  ## some subform failed, so stop here
                  failed_msg.splice 0,0,"No change to #{inst.data.collection} because of:"
                  console.log("finished with error, not calling my own action")
                  callbacks.failed(failed_msg.join "\n")
                  return
                  
                ## run the original function if we get here
                ## note that if any on_before_action_handler fails
                ## we return before gettting here
                console.log("finished succeeded(ID:#{inst.reactiveForms.ID}), calling my own action")
                old_action.call this, elms,callbacks,changed


            callback_wrap = _.extend {} , callbacks, 
              success: (msg)=>
                unless success?
                  success = true
                success_msg.push msg 
                #finished counts the number of callbacks and acts only after all have returned success or failed
                # afterflush to let invalidated ids run their dependencies
                console.log "(success)waiting for changes to propagate on form (ID:#{inst.reactiveForms.ID})[cb_id:#{callback_id.get()} ] :", inst, "with context:", this
                _ctx= callback_id.get()
                Tracker.afterFlush  ->
                  callback_id.withValue _ctx ,finished    
              failed: (msg)=>
                success= false
                failed_msg.push msg
                # afterflush to let invalidated ids run their dependencies
                #debugger
                console.log "(failed) waiting for changes to propagate on form (ID:#{inst.reactiveForms.ID})[cb_id:#{callback_id.get()} ]:", inst, "with context:", this
                _ctx= callback_id.get()
                Tracker.afterFlush  ->
                  callback_id.withValue _ctx , finished
            

            inst.on_before_action.handler.forEach (fn, idx)=>
              #fn.call this, elms,callback_wrap,changed
              console.log  "ID:#{inst.reactiveForms.ID} Calling cb [cb_id:#{idx}]", fn
              callback_id.withValue "form ID:#{inst.reactiveForms.ID}# cb_id: #{idx}", =>
                fn.call this, callback_wrap
          else
            # no subhandlers here to call success/failed
            old_action.call this, elms,callbacks,changed 
        

        ###
        ## Finally install this monster of a function
        ###
        @autorun (c)=>
          ##depend on context
          data= Template.currentData()
          #console.log "installing action"
          #unless c.firstRun
          #  console.log "actually reinstalling(ID:#{inst.reactiveForms.ID}). my data:", data
          if data.action?
            ## if it's already there just call it, and supply the original action as fourth argument
            data.action = _.wrap @data.action, (orig,args...)->
              orig.call this , args... , action
          else
            #console.log "#{@view.name} is getting action_func: ", action, this
            data.action= action
  # this is so we get to handle the argument onCreate above grabbing first
  tmpl.onCreated tmpl.created
  delete tmpl.created

  tmpl.onCreated ->
    # set my template instance and link to parent if supplied
    @reactiveForms.templateInstance = this
    

    ###
    install the form callback handlers
    ###
    for name in "before_action,success,failure".split ","
      share.install_callback_provider  name, this
    


    @autorun (c)=>
      if @reactiveForms.success.get()
        @on_success.handler.forEach (cb)->cb()
  
    #parent_form = @data.parent_form
    parent_form= share.find_parent_template tmpl.view , (inst)=> inst!=this and inst.view.name.endsWith 'bs_form'
    if parent_form
      
      # run me before you run any parents
      #debugger
      #@cb_registration = @data.parent_form.on_before_action @data.action
      if @cb_registration 
        console.error "already registered"
      @cb_registration = parent_form.on_before_action @reactiveForms.submit

      ## get submitted e.t.c. state from parent form
      @reactiveForms.parent_form= parent_form
      for key in share.sub_form_dependent_vars  
        do (key)=>
          @autorun (c)=>
            @reactiveForms[key].set @reactiveForms.parent_form.reactiveForms[key].get()
  tmpl.onDestroyed ->
    if @cb_registration
      @cb_registration.remove()
  helpers = 
    form_context:->
      _.extend {},this,
        context: share.eval_helper 'context'
    form_element_id:->
      "form_#{@reactiveForms.ID}"
    form_dbg: ->
      return Session.get('debug') or (this? and @form_dbg)
    form_id:(inst)->
      inst.reactiveForms.ID
  tmpl.instance_helpers helpers
  tmpl.onCreated ->
    if _.isFunction @data.onCreated
      @data.onCreated.call this
    if _.isFunction @data.onDestroyed
      @_destroyed_cb=@data.onDestroyed
  tmpl.onDestroyed ->
    @_destroyed_cb?.call this
  submitType: 'normal'

do(tmpl=Template.bs_form_group)->

  helpers =
    classes : ->
      if share.eval_helper('changed') or share.eval_helper('submitted')
        if share.eval_helper 'valid'
          return 'has-success'
        else
          return 'has-error'
    
    form_group_class: ->
      switch @display
        when "inline" then "form-inline"
        else "form-group"
       
    help_block_context:->
      schema = share. eval_helper 'schema' 
      ret = {}
      if info= share.schema.field::info(schema)
        ret.info = info
      unless  _.keys(ret).length or get_helper('changed')()
        #don't display helper block
        return
      return ret
    instance_contexts: ->
      
      ctx= this
      ret = [ctx]
      if min=_.isNumber(ctx.min_entries) or min= Number.parseInt(ctx.min_entries)
        for i in [1...min]
          ret.push ctx
      return ret

  _.extend helpers, share.general_form_helpers
   

  tmpl.instance_helpers helpers

      
do(tmpl=Template.bs_help_block)->
  tmpl.helpers
    infos:->
      inst = Template.instance()
      if @info?
        if _.isString @info
          return @info
        else if _.isFunction(@info)
          return @info()
      return
    show_messages:->
      share.eval_helper('changed') or share.eval_helper('submitted')


do(tmpl=Template.bs_woofmark)->
  tmpl.inheritsHelpersFrom Template.bs_input

  helpers =
    woofmark_textarea_context:(value)->
      schema = get_helper('schema')()
      placeholder = share.schema.field::placeholder schema
      inst= Template.instance()
      inst.word_count?= new ReactiveVar()
      ret=
        value:value 
        sync_text_area:true
        word_count: inst.word_count
        class: "reactive-element"
      if placeholder? or _.isNull placeholder
        ret.placeholder = placeholder
      return ret
    word_count_generator:->
      inst = Template.instance()
      schema = get_helper('schema')
      return -> 
        o= inst.word_count?.get()
        if o?
          return "#{o.word_count}"
        return
    help_block_context:->
      schema= get_helper 'schema'
      if schema?
        schema = schema()
      count_generator = helpers.word_count_generator()
      return _.extend {} , this,
        info: ->
          str = []
          if schema?.minWordCount > 1
            str.push schema.minWordCount
          str.push count_generator()
          if schema?.maxWordCount?
            str.push schema.maxWordCount
          if str.length == 2
            str = str.join "/"
          else
            str = str.join "<="
          return "Words: "+ str
  
  
  tmpl.helpers helpers

  tmpl.events

    'keyup': (e,tmpl)->
      unless $(e.target).hasClass('reactive-element')
        #reemit this event coming from the html wysiwyg div from the textelement 
        $(tmpl.find('.reactive-element')).trigger('keyup', e)
      

ReactiveForms.createElement
  template: 'bs_help_block'
ReactiveForms.createElement
  template: 'bs_form_group'


ReactiveForms.createElement
  template: 'bs_input'
  validationEvent: 'keyup'
  reset:  (el)->
    $(el).val('');
ReactiveForms.createElement
  template: 'bs_woofmark'

ReactiveForms.createElement
  template: 'woofmark_textarea'
  validationEvent: 'keyup'
  validationValue:(element,clean, template)->
    editor = woofmark.find(element);
    unless editor?
      return 
    value = editor.value()
    return value
 
    
      