do(tmpl=Template.bs_link)->
  helpers=
    sub_form_context:(inst)->
      ret = _.extend _.omit(this, ['context','data','schema','field']), 
        collection:  inst.link_collection
        schema_selector:inst.link_schema_selector
        id:inst.link_id
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
        link_schema = collection.simpleSchema(@link_schema_selector)
      unless link_schema?
        console.error "bs_link field=#{@data.field}: no link_schema supplied as an argument, or found in field's schema definition (looking for a 'join' schema key)"
        console.error "bs_link field=#{@data.field}: Not knowing what to do else, just forwarding whatever schema is in my context"
        return @schema
      return link_schema
    @link_schema = get_link_schema.call this
    

   
    @link_id = new ReactiveVar("new")
    path = form_ui.data_path(this.view, true)
    id= _.get @data.data, path
    
    if id? and id1= 'new' # When the data is not in the database yet this should not replace the "new"
      @link_id.set id

  tmpl.onRendered ->
    @autorun (c)=>
      new_val = @link_id.get()
      elm = $(@find('input[type="hidden"]'))
      elm.val new_val
      #unless c.firstRun
      console.log('triggering link.changed for new value', @link_id.get())
      elm.trigger('link.changed')
  

  tmpl.onCreated ->
    console.log("created" , this)
  tmpl.onDestroyed ->
    console.log("destroyed", this)     
    

ReactiveForms.createElement
  template: 'bs_link'
  validationEvent: 'link.changed'