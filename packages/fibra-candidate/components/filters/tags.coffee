do(tmpl= Template.tags_filter)->
  tmpl.onCreated ->
    if @data?.fields instanceof ReactiveVar
      @fields = @data.fields
    else
      @fields= new ReactiveVar @data?.fields?.split ','
    @filter=@data.filter
    @values= {}
    @value_dep= new Tracker.Dependency
    @template_id=Random.id()
    @autorun =>
      @value_dep.depend()
      lodash_template_arg = 
        fields:@fields.get()
      unless _.keys(@values).length and fields?.length
        @filter.set "tags_filter:#{@template_id}", undefined
      @filter.set "tags_filter:#{@template_id}", _.flatten _.values(@values).map (lodash_template)->  JSON.parse lodash_template lodash_template_arg

  tmpl.onRendered ->
    @data = new ReactiveVar
    
   
    @$input= $(@find('input')).selectize
      plugins: ['restore_on_backspace']
      delimiter:','
      #createOnBlur:true
      persist: false
      create: (input)=>
        ret=
          value:{}
          text:input
        ret.value["<%=field%>"]=
          $regex: ".*#{input}.*"
          $options: 'i'
        ret.value =  "[<%_.forEach(fields, function(field, idx){  %><%=idx && ',' || '' %>" + JSON.stringify(ret.value) + "<% }); %>]"
        return ret
        text:input
      onItemAdd: (value,$item)=>
        @values[value]= _.template(value)
        @value_dep.changed()
        return
      onItemRemove:(value)=>
        delete @values[value]
        @value_dep.changed()
        return
      render:
        option_create: (data,escape)=>
          unless @option_create_element?
            @option_create_element = document.createElement('div')
            @option_create_element.setAttribute('class','create col-md-12')
            Blaze.renderWithData Template.tags_filter_option_create, @data, @option_create_element
          @data.set
            onDestroyed: =>
              console.log "destroying #{@option_create_element}" 
              delete @option_create_element
            input: data.input
          #data = _.extend {selec}
          return @option_create_element
      #THIS
      #openOnFocus: false
    #AND this disables the dropdown
    # see https://github.com/selectize/selectize.js/issues/981
    #selectize= @$input[0].selectize
    #selectize.$control_input.on 'keypress', -> 
    #  selectize.close() 
    #selectize.on 'type', -> 
    #  selectize.close() 

  tmpl.onDestroyed ->
    debugger
tags_filter_for_collection =  (collection_name)->
  form_ui.filter_compiler.add collection_name ,
    (dict)->
      #17 is default random id 
      all = dict.all()
      filters_by_id= {}
      for key,val of all
        unless val?
          continue
        match  =  /^tags_filter:(.{17})$/.exec(key)
        if match?
          bit= filters_by_id[match[1]]?=[]
          bit.push val...
      for key, vals of filters_by_id
        if vals?
          for val in vals
            @$or val
      return
tags_filter_for_collection 'submissions'

do(tmpl=Template.tags_filter_option_create)->
  tmpl.onCreated ->
   @autorun (c)=>
    data=Template.currentData().get()
    if data?.onDestroyed
      @destroyed_cb = data.onDestroyed
      c.stop()
  tmpl.helpers
    data: ->@get()
  tmpl.onDestroyed ->
    @destroyed_cb?.call(this)
    console.log('tags_filter_option_create destroyed' )

