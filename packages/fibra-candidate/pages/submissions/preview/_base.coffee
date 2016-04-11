_= lodash

do(tmpl=Template._display_base)->
  tmpl.onCreated ->
    @schema = Submissions.simpleSchema
        draft:false
  tmpl.instance_helpers
    schema:(inst)->
      inst.schema
    field_name:(inst,field)->
      schema=inst.schema.schema(field)
      if schema.label
        return schema.label
      else
        return field
do(tmpl=Template.preview_modal)->
  helpers=
    dynamic_template_ctx:->
do(tmpl=Template.object_display)->
  
  helpers=
    object_label: ->
      if @is_list
        name= "#{@name}.$"
        debugger
      else
        name= "#{@name}"
      if @data? and 'show_object_label' of @data and not @data.show_object_label
        #show_object_label is falsey
        return
      if (def =@schema?.schema(name)) and def.label
        return def.label
      else
        words = @name.split('.')
        words.map (w)-> w[0].toUpperCase() + w[1...]
        return words.join ' '
    keys: ->
      if @is_list
        name= "#{@name}.$"
        debugger
      else
        name= "#{@name}"
      if @keys 
        keys = @keys
      else
        if @is_list
          keys=[]
          for datum in @data
            keys.push _.keys(datum)...
          keys= _.uniq keys
          debugger
        else
          keys = _.keys(@data)
      keys.map (key)=>
        def = @schema?.schema(SimpleSchema._makeGeneric(@name) + ".#{key}") 
        if def?.label?
          return def.label
        else
          return key[0].toUpperCase() + key[1...]
    value: ->
      debugger
      if @is_list
        _.range(@data.length).map (idx)=>
          _.extend @this,
            name: "#{@name}.#{idx}"
            data: @data[idx]

      else
        [this]
  tmpl.instance_helpers helpers
do(tmpl=Template._object_row_display)->
  
  helpers=
    values: ->
      _.map @data, (val,key)=>
        def = @schema?.schema(@name + ".#{key}")
        return val
  tmpl.instance_helpers helpers

do(tmpl=Template.object)->
  helpers=
    object_ctx:->
      schema_name = SimpleSchema._makeGeneric(@name)
      subschema_keys = _.keys(this.schema.schema()).filter((key)=>key.startsWith(schema_name))
      unless @data and @name and data= _.get(@data ,@name)
        return 
      data:data
      schema: @schema.pick(subschema_keys)
      is_list: @is_list
      name: @name
    object_label:->
      if @name
        if label=@schema?.schema(@name)?.label
          return label
        else 
          return @name[0].toUpperCase() + @name[1...]
      else
        return 'Unknown Object'
  tmpl.instance_helpers helpers
do(tmpl=Template.object_or_alert)->
  helpers=
    has_object:(inst)->
      @data and @name and data= _.get(@data ,@name)
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom 'object'
