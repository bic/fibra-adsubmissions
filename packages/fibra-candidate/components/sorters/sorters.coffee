do(tmpl=Template._sort_base)->
  tmpl.onCreated ->
    @options= @data.query_options
    @glyphicon_classes?=
      'asc': 'glyphicon-sort-by-alphabet'
      'desc': 'glyphicon-sort-by-alphabet-alt'
      
  helpers=
    glyphicon_class:(inst)->
      opt = inst.options.get 'sort'
      debugger
      if opt?
        opt = opt.filter (sorter)-> sorter[0] == inst.name
      if not opt?[0]?[1]?
        return inst.glyphicon_classes.asc
      else
        
        direction = switch opt[0][1]
          when 1 then 'asc'
          when -1 then 'desc'
          else opt[0][1]
        direction ?='asc'
        return inst.glyphicon_classes[direction]
    is_active:(inst)->
      debugger
      opt = inst.options.get 'sort'
      if opt?
        for val,key in opt
          if val[0]== inst.name
            if 0<= [-1,  'desc'].indexOf val[1]
              return 'desc'
            else if 0<= [1, 'asc'].indexOf val[1]
              return 'asc'
            else
              console.warn "unkknown value for sort key #{val[0]}: #{val[1]}"
              return false
      return false
    active_class:(inst)->
      switch helpers.is_active.call(this,inst)
        when 'asc' then 'btn-primary'
        when 'desc' then 'btn-primary'
        else
          'btn-default'
    nested_sort_index:(inst)->
      opt = inst.options.get 'sort'
      unless opt? and opt.length >1
        return false
      if opt?
        for val,idx in opt
          if val[0]== inst.name
            if 0<= [1,-1, 'asc', 'desc'].indexOf val[1]
              return idx+1 
            else
              console.warn "unknown value for sort key #{val[0]}: #{val[1]}"
              return false
      return false

      
  tmpl.instance_helpers helpers
  tmpl.events
    'click .do-toggle': (e,inst)->
      debugger
      opt= inst.options.get 'sort'
      unless opt
        inst.options.set 'sort' , [[inst.name, 'asc']]
      else

        for key, idx in opt
          if key[0]== inst.name
            prev= key[1]
            break
        next = switch prev
          when 1 then 'desc'
          when 'asc' then 'desc'
          when 'desc' then undefined
          when '-1' then undefined
          else 'asc'
        unless e.metaKey or e.ctrlKey
          #multiple selections with metaKey
          if idx < opt.length
            opt = [opt[idx]]
            idx=0
          else
            opt= []
        if idx < opt.length
          if next?
            opt[idx][1]=next
          else
            opt= opt.filter (entry,i)->i!=idx
        else
          opt.push [@name,'asc']
        if opt.length
          inst.options.set 'sort', opt
        else
          inst.options.set 'sort', undefined
do(tmpl=Template.alpha_sort_option)->
  tmpl.onCreated ->
    @name=@data.name
    # default glyphicon classes are o.k.
  tmpl.inheritsHelpersFrom '_sort_base'
  tmpl.inheritsHooksFrom '_sort_base'
  tmpl.inheritsEventsFrom '_sort_base'

do (tmpl=Template.numeric_sort_option)->
  tmpl.onCreated ->
    @name=@data.name
    @glyphicon_classes=
      asc: 'glyphicon-sort-by-order'
      desc: 'glyphicon-sort-by-order-alt'  
  tmpl.inheritsHelpersFrom '_sort_base'
  tmpl.inheritsHooksFrom '_sort_base'
  tmpl.inheritsEventsFrom '_sort_base'


      

