_= lodash
do(tmpl=Template.jury_submissions_list)->
  tmpl.onCreated ->
    @fields_ref=new ReactiveVar 'submitter_contact.name,credit_contacts.name'.split ','
    state = Session.get('submissions_list_state')

    @filter=new ReactiveDict 
    
    if state?.filter
      @filter._setObject state?.filter 
    @filter.set 'is_trashed', false
    @filter.set 'sections', []
    @autorun =>
    @compiled_filter = new ReactiveVar null, EJSON.equals
    @query_options= new ReactiveDict
    if state?.query_options
      @query_options._setObject state?.query_options 
    
    
    @autorun =>
      last = Tracker.nonreactive ->
        Session.get 'submissions_list_state'
      last ?={}
      _.extend last, 
        filter: @filter.all()
      Session.set('submissions_list_state' ,last)
    @autorun =>
      last = Tracker.nonreactive ->
        Session.get 'submissions_list_state'
      last ?={}
      _.extend last, 
        query_options: @query_options.all()
      Session.set('submissions_list_state',last)

    @autorun =>
      @compiled_filter.set form_ui.filter_compiler.compile('submissions', @filter)
    @autorun =>
      opts = @query_options.all()
      filter= @compiled_filter.get()
      Meteor.subscribe 'jury_submission_publication', filter, opts
    @jury_submission_widget_state=new ReactiveDict


  helpers=
    debug:(inst)->
      Session.get 'debug'
    filter: (inst)->
      inst.filter
    filter_json:(inst)->
      return JSON.stringify(inst.compiled_filter.get(), null,2)
    submissions:(inst)->
      opts = inst.query_options.all()
      Submissions.find(inst.compiled_filter.get(), opts )
    query_options:(inst)->
      inst.query_options
    query_options_json:(inst)->
      JSON.stringify inst.query_options.all(), null, 2
    fields_ref:(inst)->
      inst.fields_ref
    compiled_filter:(inst)->
      inst.compiled_filter
    widget_force_fields:(inst)->
      ret= inst.query_options.get('sort')?.map (sort_bit)->sort_bit[0]
      if ret? and ret.length
        return ret
      else
        return
    jury_submission_widget_state:(inst)->
      inst.jury_submission_widget_state


  tmpl.instance_helpers helpers
do(tmpl=Template.jury_submission_widget)->
  tokenize= (data, key,regex_def)->
    ret = []
    key_parts = key.split '.'
    val = data
    for key_part , key_idx in key_parts
      unless val?
        break
      if _.isArray val
        for arr_element , idx in val
          sub_rets = tokenize arr_element, key_parts[key_idx...].join('.'), regex_def
          ret.push.apply ret, sub_rets.map (sub_ret)->
            _.extend sub_ret,
              name: key_parts[0...key_idx].join('.') + ".#{idx}." + sub_ret.name
      val = val[key_part]
    
    if _.isString val
      highlight_groups= []
      rex = new RegExp regex_def.$regex.split('.*').map((bit,idx)->if bit.length then ( highlight_groups.push Math.max(idx*2-1,0);"(#{bit})") else bit).join('(.*)'), regex_def.$options
      match= rex.exec val
      if match
        bits=  match.filter((x,idx)->idx!=0).map (bit,idx)->
          value:bit
          highlight:0<=highlight_groups.indexOf idx
        ret.push
          name:key
          field_value_bits:bits
          value: val
    for val in ret
      val.field_value_bits= val.field_value_bits.filter (bit)->
        return bit.value?.length >0
    return ret
  extract_driver=
    $and:(data, and_clause)->
      ret= []
      for query in and_clause
        for key, val of query
          if extract_driver[key]
            ret.push (extract_driver[key](data, val) or [])...
          else if val.$regex?
            match = tokenize data , key, val
            if match? and match.length
              ret.push match...
      return ret
    $or:(data, or_clause)->
      ret= []
      for query in or_clause
        for key, val of query
          if extract_driver[key]
            ret.push (extract_driver[key](data, val) or [])...
          else if val.$regex?
            match = tokenize data , key, val
            if match? and match.length
              ret.push match...
      return ret
    


  extract_matching_fields=(data, filter)->
    ret= []
    for key, val of filter
      if key of extract_driver
        ret.push extract_driver[key](data,val)...
    return ret
      

  helpers=
    submission_name:->
      ret = []
      ret.push @title or "(no title)"
      ret.push @brand or "(no brand)"
      return ret.join "/"
    user:->
      unless @data?.owner_account
        return
      Meteor.users.findOne(@data.owner_account)  
    labels:->
      ret=[]
      
      if @data.sections
        evaluations = Evaluations.find
          submission:@data._id
          createdBy:Meteor.userId()
          section:
            $in:_.map @data.sections, 'name'
         
        missing= _.difference _.map(@data.sections, 'name' ), evaluations.fetch().map (x)->x.section
        partial= _.compact evaluations.fetch().filter (evaluation)-> 
          val= _.values _.pick evaluation ,share.criteria
          if val.length == 0
            missing.push evaluation.section
            return false
          else if val.length < share.criteria.length
            return true
          else
            return false
        partial = _.map partial, 'section'

        if missing.length == _.uniqBy(this.data.sections, 'name').length
          ret.push 
            label_class: 'label-primary'
            label: "No Evaluation"
        else if partial.length or missing.length
          ret.push
            label_class: 'label-info'
            label: 'Partial Evaluation'
        else
          ret.push 
            label_class:'label-default'
            label: 'Evaluated'
      return ret
    display_fields:->
      ret= []
      schema= Submissions.simpleSchema
        draft:true
      schema = schema.schema()
      if @filter
        ret.push extract_matching_fields(@data, @filter.get())...
      if @fields
        field_set= [@fields...]
        existing = _.map ret, 'name'
        dif = _.difference field_set,existing
        if dif.length
          debugger
        for name in dif
          if _.get  @data, name
            debugger
          ret.push
            name:name
            value:_.get  @data, name
            field_value_bits:[
                highlight:false
                value:_.get @data, name
              ]
        #add the fields not already added to ret
      if ret.length
        return ret
      else
        return
    field_name:->
      schema= Submissions.simpleSchema
        draft:true
      schema = schema.schema()
      schema_name= SimpleSchema._makeGeneric @name
      partial= ''
      name_hierarchy= []
      for bit, idx in schema_name.split('.')
        if partial.length
          partial+= ".#{bit}"
        else
          partial= bit
        if schema[partial]?.label?
          name_hierarchy.push schema[partial].label
      name_hierarchy = _.uniq name_hierarchy
      return name_hierarchy.join '>'
    show_more_btn:->
      return false
    impersonate_path:->
      data= Template.parentData (ctx)->
        if ctx?.data?
          return true
      return Blaze._globalHelpers.pathFor.call(this,'submissions.candidate_edit.preview' ,{hash:{id:data.data._id}})
  tmpl.events
    'click .do-preview': (e,inst)->
      Modal.show 'preview_modal' , ->
        unless (id = inst.data.data._id)?
          throw new Meteor.Error("cannot find the id of the submission")
        template: 'evaluate_submission'
        data:
          data: Submissions.findOne(id)
          id: id
    'click .do-edit':(e,tmpl)->
      Router.go 'submissions.candidate_edit.basics',{id:tmpl.data.data._id},
        return_to: 'admin.submissions'
      
  tmpl.instance_helpers helpers

do(tmpl=Template.show_hide_others)->
  helpers=
    label: ->
      ret = Session.get 'show_hide_others'
      if _.isBoolean(ret) and not ret
        return "My grades only"
      else
        return "Everybody's grades"
  tmpl.instance_helpers helpers
  tmpl.events
    'click .do-toggle-others':(e,tmpl)->
      old = Session.get('show_hide_others')
      debugger
      unless old?
        Session.set 'show_hide_others', false
      else
        Session.set 'show_hide_others', not old







