

_=lodash
do(tmpl=Template.admin_accounts)->
  add_state= (name, parent_levels, click_selector)->
    click_selector?=name
    helper={}
    data_func= ()->
      if parent_levels
        Template.parentData()
      else
        this
    helper["#{name}"] = (inst)->
      states= inst.company_states.get(data_func.call(this)._id)
      return states?[name]
    tmpl.instance_helpers helper

    evt={}
    evt["click #{click_selector}"] = (e,inst)-> 
        data= Blaze.getData($(e.currentTarget).parents('.account-entry')[0])
      
        id = data._id
        prev= inst.company_states.get(id)
        prev?={}
        prev[name] = not prev[name]
        debugger
        inst.company_states.set id, prev
    tmpl.events evt


    tmpl.instance_helpers 
  tmpl.onCreated ->
    @hdlr = @subscribe 'accounts'
    @company_states = new ReactiveDict()

  tmpl.instance_helpers
    ready:(inst)->inst.hdlr.ready()
    accounts:(inst)->
      Users.find()
    is_admin:->
      Users.isAdmin @_id
    impersonate_path:->
      debugger
      return Blaze._globalHelpers.pathFor.call this,'submissions.candidate_edit.all_submissions',{}
    account_stats:(inst)->

      cur = Submissions.find
        owner_account: @_id
      

      ret=
        submissions:[]
        sections:[]
        review_requests:[]
        trashed:[]
        price:0
      cur.forEach (doc)->
        if doc.trashed
          ret.trashed.push doc._id
        else
          ret.submissions.push doc._id        
          sections= _.map doc.sections, 'name'
          ret.sections.push sections...
          if sections.length
            ret.price+=99 + 50*(sections.length-1)
          if doc.review_request
            ret.review_requests.push(doc._id)
      for key in 'sections,submissions,review_requests,trashed'.split(',')
        ret["#{key}_count"] = ret[key].length
      return ret


  add_state 'show_company_details', 1, '.do-toggle-company-details' 
  add_state 'show_submission_details', 1, '.do-toggle-submission-details' 
  tmpl.events
    'click .do-remove-admin':(e,inst)->
      debugger
      data = Blaze.getData($(e.currentTarget).parents('.account-entry')[0])
      
      Users.update data._id, 
        $pull:
          roles: 'admin'
    'click .do-make-admin':(e,inst)->
      data = Blaze.getData($(e.currentTarget).parents('.account-entry')[0])
      Users.update data._id, 
        $push:
          roles: 'admin'
      
do(tmpl=Template.submission_details)->
  helpers=
    submissions:->
      Submissions.find 
        _id:
          $in: @submissions
      
    submission_name:->
      ret = []
      ret.push @title or "(no title)"
      ret.push @brand or "(no brand)"
      ret.push @submitter_contact?.name or "(no submitter name)"
      return ret.join "/"
  tmpl.helpers helpers


