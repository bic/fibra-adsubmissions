do(tmpl= Template.tristate_btn)->
  helpers=
    glyphicon_boolean:(inst)->
      if val= inst.filter.get inst.name
        'glyphicon-check'
      else if val?
        'glyphicon-unchecked'
      else
        'glyphicon-check invisible'

    is_true:(inst)->
      if inst.filter.get inst.name
        return true
    is_undefined:(inst)->
      ret= inst.filter.get inst.name
      return not ret?
    is_false:(inst)->
      ret= inst.filter.get inst.name
      return ret? and not ret

  tmpl.onCreated ->
    #@filter needs to be reactive
    @filter=@data.filter
  tmpl.onRendered ->
    unless @name
      throw new Error "No name set on tristate instance"
    $(@findAll('[data-toggle="tooltip"]')).tooltip()
  tmpl.instance_helpers helpers
  tmpl.events
    'click .do-toggle': (e,inst)->
      cur = inst.filter.get inst.name
      if cur?
        if cur
          inst.filter.set inst.name , not cur
        else
          inst.filter.set inst.name, undefined
      else
        inst.filter.set inst.name, true
create_filter = (tmpl,name, collection_name,generator_func)->
  if _.isFunction collection_name
    generator_func= collection_name
    collection_name= 'submissions'
  tmpl.onCreated ->
    @name= name
  tmpl.inheritsHelpersFrom 'tristate_btn'
  tmpl.inheritsHooksFrom 'tristate_btn'
  tmpl.inheritsEventsFrom 'tristate_btn'
  if generator_func?
    form_ui.filter_compiler.add collection_name, generator_func
create_filter Template.review_filter, 'reviewed', 
  (dict)->
    if(val= dict.get 'reviewed')?
      val = not not val
      @$and 
        last_review:
          $exists:val
create_filter Template.request_for_review_filter, 'review_requested',
 (dict)->
    if(val= dict.get 'review_requested')?
      val = not not val
      @$and 
        review_request:
          $exists:val

create_filter Template.contact_filter, 'has_contact',
  (dict)->
    if(val= dict.get 'has_contact')?
      val = not not val
      @$and 
        submitter_contact:
          $exists:val


create_filter Template.brand_filter, 'has_brand',
  (dict)->
    if(val= dict.get 'has_brand')?
      val = not not val
      @$and 
        brand:
          $exists:val
create_filter Template.title_filter, 'has_title',
  (dict)->
    if(val= dict.get 'has_title')?
      val = not not val
      @$and 
        title:
          $exists:val
create_filter Template.is_trashed, 'is_trashed',
  (dict)->
    if(val= dict.get 'is_trashed')?
      val = not not val
      if val
        @$and 
          trashed:true
      else
        @$and
          $or:[
            trashed:false
            ,
            trashed:
              $exists:false
          ]
create_filter Template.evaluated_filter, 'evaluated_filter',
  (dict)->
    arr= Tracker.nonreactive ->
     ret= Evaluations.find
        createdBy: Meteor.userId()
        submission:
          $exists:true
        context:
          $exists:true
        originality:
          $exists:true
        execution:
          $exists:true



          
      ,
        sort:
          _id:1
      ret.fetch()
    ids= _.sortedUniq arr.map (doc)->doc.submission
    if(val= dict.get 'evaluated_filter')?
      val = not not val
      if val
        @$and 
          _id:
            $in: ids
      else
        @$and
          _id:
            $nin:ids

#create_filter Template. ''

  

