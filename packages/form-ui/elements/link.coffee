do(tmpl=Template.bs_link)->
  helpers=
    sub_form_context:(inst)->
      ret = _.extend _.omit(this, ['context','data','schema','field']), 
        collection:  inst.link_collection
        schema_selector:inst.link_schema_selector
        id:inst.link_id
        onCreated: ->
          inst.linked_form = this
          @autorun (c)=>
            debugger
            @id.dep.depend()
            unless c.firstRun
              @data.data = Template.currentData().data
              @reactiveForms.resetForm()
        data: share.collection_for_name(inst.link_collection).findOne(inst.link_id.get())
      if inst.reactiveForms.parentData?
        ret.parent_form= inst.reactiveForms.parentData.templateInstance
      return ret
    link_id:(inst)->
      inst.link_id.get()
    dbg_id: ->
      @dbg_id or Session.get('debug')
  tmpl.instance_helpers helpers
  tmpl.onCreated ->
    
    get_link_schema = ->
      if @link_schema
        return @link_schema
      schema = share.get_helper('schema')?()
      if schema?.join?
        @link_collection=schema.join.collection
        collection = share.collection_for_name @link_collection
        if @data.link_schema_selector
          @link_schema_selector= @data.link_schema_selector
        else if (form = @reactiveForms.parentData?.templateInstance)?
          while form
            @link_schema_selector= form.schema_selector
            if @link_schema_selector?
              break
            else
              form = form.reactiveForms.parent_form
        link_schema = join.config.schema_for_doc collection, @link_schema_selector

      unless link_schema?
        console.error "bs_link field=#{@data.field}: no link_schema supplied as an argument, or found in field's schema definition (looking for a 'join' schema key)"
        console.error "bs_link field=#{@data.field}: Not knowing what to do else, just forwarding whatever schema is in my context"
        return @schema
      return link_schema
    @link_schema = get_link_schema.call this
    

   
    @link_id = new ReactiveVar()
    @autorun (c)=>
      data= Template.currentData()
      path = form_ui.data_path(this.view, true)
      id= _.get data.data, path
      @link_id.set id

    if this.data.schema?.schema?()[this.data.field].join?.deny_insert
      @autorun (c)=>
        id = @link_id.get()
        debugger
        unless id? and id != 'new'
          @invalid_key=@reactiveForms.schemaContext.addInvalidKeys [
            name:this.data.field
            type: "mustChoose"
            value: id
          ]
        else
          debugger



  tmpl.onRendered ->
    
   



    #@autorun (c)=>
    #  unless 
    elm = $(@find('input[type="hidden"]'))
    @autorun (c)=>
      id = @link_id.get()
      if elm.val() != id
        elm.val id
        debugger
        console.log('triggering link.changed for new value', @link_id.get())
        elm.trigger('link.changed')



  tmpl.onCreated ->
    console.log("created" , this)
  tmpl.onDestroyed ->
    console.log("destroyed", this)     
    

ReactiveForms.createElement
  template: 'bs_link'

  validationEvent: 'link.changed'