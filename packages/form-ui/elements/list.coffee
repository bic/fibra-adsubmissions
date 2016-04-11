_= lodash


do(tmpl=Template.bs_list)->
  ReactiveForms.createElement
    template: 'bs_list'
    validationValue: (el, clean, template)->
        debugger

  # workaround the impossibility of 
  tmpl.onCreated ->
    inst = this
    @update_pull=[]
    @update_pull_cb_handle= @reactiveForms.parentData.templateInstance.on_update ( collection,id,mod, schema_selector )=>
      path= form_ui.data_path (inst.view)
      debugger
      old_vals= collection.findOne(id)
      arr = _.get old_vals , path
      for elm, i in arr
        if @update_pull.indexOf(i) > -1
          arr[i]=null
      debugger
      arr = _.compact arr

      mod = 
        $set: _.fromPairs [[path.join('.'),arr]]
      _.defaults mod.$set, schema_selector
      collection.update id, mod, (err,success)=>
        if err
          form_ui.err "Error pulling indices #{@update_pull.join(',')} from path", err
        else
          @update_pull=[]
  tmpl.onDestroyed ->
    @update_pull_cb_handle.remove()

  tmpl.onCreated ->
    @child_tracker =
      add: (subelement)->
        @_children_autorun.push Tracker.autorun ->
          #subelement is implied by Template.instance() dynamic logix
          share.eval_helper 'value'
          
        @_children.push subelement
      remove:(subelement)->
        idx = @_childen.indexOf(subelement)
        if idx <0
          console.error("bs_list: child requested removal of dependendency i didn't have")
        @_children.splice idx,1
        @_children_autorun[idx].stop()
        @_children_autorun.splice idx,1

      _children: []
      _children_autorun: []
   
  tmpl.onCreated ->
    @counter= new ReactiveDict
    inst = this
    @autorun =>
      @counter.set 'min' , do ->
        schema = share.get_helper('schema')()
        if @min?
          min= @min
        else
          min = -Infinity        
        if schema?.minCount?
          if min < schema.minCount
            if @min?
              console.warn "bs_list field #{@field}: Ignoring the min=#{min} from the data context in favor of the min from the schema (#{@schema.minCount})"
            min= schema.minCount
        return min? and min or 0
      @counter.set 'max', do ->
        schema = share.get_helper('schema')()
        if @max?
          max= @max
        else
          max = Infinity
        if schema?.maxCount?
          if max > schema.maxCount
            if @max?
              console.warn "bs_list field #{@field}: Ignoring the max=#{max} from the data context in favor of the max from the schema (#{@schema.maxCount})"
            max= schema.maxCount
        return max? and max or Infinity
    @autorun =>
      @counter.set 'count',do =>
        ##
        ## TODO: What is there to do if there is more data in @data than allowed by max? 
        ##
        count = Template.currentData().count
        min = inst.counter.get('min')
        max = inst.counter.get('max')
        #data= Template.currentData()
        #my_path= form_ui.data_path()
        #check_value=_.get data?.data, my_path
        
        my_value = _this.reactiveForms.value.get()
        if my_value? and not _.isArray my_value
          debugger
          form_ui.except( "my value is not an array! value:" , my_value)

        if my_value? and my_value.length
          # if the current value is 0 still show a form
          count= my_value.length
        else if min >max
          throw new Error ("bs_list field #{@field}: min=#{min} > #{max} ")

        else if count?
          if min? and min > count
            console.warn("bs_list field #{@field}: adjusted count=#{count} to min=#{min}")
            count= min
          if max? and count> max
            console.warn("bs_list field #{@field}: adjusted count=#{count} to min=#{min}")
            count= max
        else
          if min? and min >= 0
            count= min
          else if max? and max>=1
            count= 1
          else
            count=0
        return count  
  tmpl.onCreated ->
    @state = new ReactiveVar('created')
  tmpl.onRendered ->
    @state.set('rendered')
  tmpl.onDestroyed ->
    @state.set('destroyed')
  with_inst= (f)->
    ->f.call this, Template.instance(), arguments...  
  helpers=
    min: (inst)->inst.counter.get('min')
    max: (inst)->inst.counter.get('max')
    list_dbg: (inst)->
      return inst.data.list_dbg or Session.get('debug')
    form_id:(inst)->
      if inst.state.get() == 'rendered'
        forms= $(inst.findAll('form'))
        picked_form= null
        forms.each (idx,elm)=>
          
          share.each_parent_template elm, (parent_inst)=>
            if parent_inst.data?.index == @index
              ## only look for my index
              if parent_inst.view.name.endsWith 'bs_form'
                picked_form= parent_inst
              else if parent_inst==inst
                #is a direct descendant
                return false
        return picked_form.reactiveForms.ID
      else
        return

    count: (inst)->inst.counter.get('count')
    show_add_btn: (inst)-> inst.counter.get('count') < inst.counter.get('max')
    show_remove_btn: (inst)->inst.counter.get('count') > inst.counter.get('min') 
    element_ctx:->
      _.extend this,{}

    element_sub_form_ctx:(inst)->
      index = @index
      count = @count
      ret = _.extend {},this,
        field: do => 
          debugger
          @field+".$"
        schema: do =>
          debugger
          unless @field
            form_ui.err "No field supplied, thus cannot pick my field and this list's contents will contain nothing"
          if inst.reactiveForms.schema?
            schema_def = _.pickBy inst.reactiveForms.schema.schema(), (val,key)=>
              key.startsWith(@field) or key=='_id'
            return new SimpleSchema schema_def
        collection: @collection or inst.reactiveForms.parentData.templateInstance.collection
        id: inst.reactiveForms.parentData.id
        #action:(elm,callbacks,changed)->
        #  debugger
        is_first: @index == 0
        is_last: @index == inst.counter.get('count')
        no_db_operations:true
        data: do =>
          data = @data or {}
          val = inst.reactiveForms.value.get()
          data_path= form_ui.data_path()
          debugger
          _.set data, data_path, val
          console.error 'set data to ' , JSON.stringify val
          return data
        onCreated: ->
          form = this
          ## this is called by the subform
          this.reactiveForms.setFormDataField = _.wrap  this.reactiveForms.setFormDataField ,   (old,field, value, fromUserEvent)->
            data_path = form_ui.data_path(Template.instance().view)
            my_path = form_ui.data_path(inst.view)
            if my_path[my_path.length-1] >= inst.counter.get('count')
              console.error "got update from index #{my_path[my_path.length-1]} which is out of scope"
              return
            rel_value_path = data_path[my_path.length...]
            old.call this, field ,value, fromUserEvent
            
            
            # we give the parent path a different identity in ode
            
            cur_value= _.cloneDeep inst.reactiveForms.value.curValue
            cur_value ?= new Array(inst.counter.get('count'))
            _.set cur_value, rel_value_path, value
            inst.reactiveForms.setValue cur_value , fromUserEvent
            this.validate()


        
      if inst.reactiveForms.parentData?.templateInstance
        #his will throw if templateInstance is not set!
        ret.parent_form= inst.reactiveForms.parentData.templateInstance
      for helper in "min,max,count".split ","
        ret[helper]= share.eval_helper helper
      # setup show_remove btn for descendents
      unless Template.currentData()?.show_remove_btn
        if inst.counter.get('count') <= inst.counter.get('max')
          ret.show_remove_btn = true
      unless Template.currentData()?.show_add_btn
        if  @index== @count and @max > @count #only the last element gets to put an add button 
          ret.show_remove_btn = true
      return ret

  tmpl.instance_helpers helpers
  
  find_index_for_event_origin = (view, origin)->
    #
    #Searches the view hierarchy up to self, and then
    #finds closest with block with an index definition
    #
    parent_withs= []
    while view
        if view.name=="with"
          parent_withs.push view
        if view.name== 'Template.bs_list' and view.templateInstance==origin
          #That's me
          break
        view = view.originalParentView or view.parentView
      
    for i in [parent_withs.length-1..0] 
      ctx = parent_withs[i]
      if (idx= ctx.dataVar.get()?.index)?
        return idx
    return 

  tmpl.events
    'click .btn.btn-add': (e,inst)->
      e.preventDefault() # This is not a submit button
      inst.counter.set 'count', inst.counter.get('count')+1
      val = inst.reactiveForms.value.get() 
      if val?
        val.push undefined
        inst.reactiveForms.setValue(val,true)
      inst.update_pull = inst.update_pull.filter (x)-> x!= val.length
      
    'click .btn.btn-remove': (e,inst)->
      e.preventDefault()
      view = Blaze.getView(e.currentTarget)
      index = find_index_for_event_origin view , inst
      val = inst.reactiveForms.value.get()
      val = val.filter (elm,idx)->idx !=index
      inst.reactiveForms.setValue(val,true)
      debugger
      if -1 == inst.update_pull.indexOf val.length
        inst.update_pull.push(val.length);  
      return
    

