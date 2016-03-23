_= lodash

do(tmpl=Template.bs_list)->
  tmpl.onCreated ->
    inst = this
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
      ret = _.extend {}, this ,
        schema: do =>
          unless this.field
            form_ui.err "No field supplied, thus cannot pick my field and this list's contents wil contain nothing"
          keys = _.keys(inst.reactiveForms.schema?.schema()).filter  (key)=>key.startsWith this.field 
          inst.reactiveForms.schema?.pick( keys)
        collection: @collection or inst.reactiveForms.parentData.templateInstance.collection
        #action:(elm,callbacks,changed)->
        #  debugger
        is_first: @index == 0
        is_last: @index == inst.counter.get('count')
        no_db_operations:true
        onCreated: ->
          form = this
          ## this is called by the subform
          this.reactiveForms.setFormDataField = _.wrap  this.reactiveForms.setFormDataField ,   (old,field, value, fromUserEvent)->
            old.call this, field ,value, fromUserEvent
            
            #list template current value
            current_value= inst.reactiveForms.value.get()
            
            #make sure array is initialized
            current_value?=new Array(inst.counter.get 'count')

            # get the values of the subform
            list_elm = @validatedValues 
            # now strip off the path up to the list field
            for key in inst.reactiveForms.field.split '.' 
              if list_elm? 
                parent = list_elm
                parent_key= key
                list_elm=list_elm[key]
            #remove the root $ (this is a list template) 
            if list_elm? && '$' of list_elm
              list_elm=list_elm['$']
            #now merge the object. Not quite sure here that this is nesessary
            #set might be enough
            
            current_value[index]=list_elm
            parent[parent_key]=current_value
            #  _.merge current_value[index], list_elm
            
            #Finally set the list template value
            inst.reactiveForms.setValue current_value, fromUserEvent
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
      inst.counter.set 'count', inst.counter.get('count')+1
      val = inst.reactiveForms.value.get() 
      if val?
        val.push undefined
        inst.reactiveForms.setValue(val,true)
      e.preventDefault() # This is not a submit button
    'click .btn.btn-remove': (e,inst)->
      inst.counter.set 'count', Math.max inst.counter.get('min'), inst.counter.get('count')-1
      e.preventDefault()
      view = Blaze.getView(e.currentTarget)
      index = find_index_for_event_origin view , inst
      Tracker.afterFlush =>
        # setValue will trigger the link set again. to avoid that first remove the template
        # and than set the lists value
        val = inst.reactiveForms.value.get()
        if val?
          val = val.filter (elm,idx)->idx !=index
          inst.reactiveForms.setValue(val,true)
      #now what to do with the array index
      

ReactiveForms.createElement
  template: 'bs_list'
  validationValue: (el, clean, template)->
      debugger
