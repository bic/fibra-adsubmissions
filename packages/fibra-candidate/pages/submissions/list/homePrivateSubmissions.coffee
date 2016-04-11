do(tmpl=Template.homePrivateSubmissions)->
  tmpl.onCreated ->
    
    @trash_count=new ReactiveVar(0)
    @show_trashed= new ReactiveVar(false)
   
    
    @filter = new ReactiveVar({})
    @autorun =>
      if @show_trashed.get()
        @filter.set({})
      else
        @filter.set
          $or:[
            trashed:
              $exists:false
          ,
            trashed:false
          ]
    @autorun =>
      @trash_count.set Submissions.find({trashed:true}).count()
  helpers= 
    has_trashed_items:(inst)->
      return inst.trash_count.get() > 0
    show_trashed: (inst)->
      return inst.show_trashed.get()
    submission_list:(inst)-> Submissions.find(inst.filter.get())
    trash_btn_label:(inst)->
      prefix = inst.show_trashed.get() and "Hide" or "Show"
      "#{prefix} Trashed (#{inst.trash_count.get()})"

   

  tmpl.instance_helpers helpers
  tmpl.events
    'click .toggle-trashed':(e,inst)->
      inst.show_trashed.set(not inst.show_trashed.get())
    

do(tmpl=Template.submission_link)->

  helpers=
    title: ->
      ret = []
      ret.push @title or "(no title)"
      ret.push @brand or "(no brand)"
      ret.push @submitter_contact?.name or "(no submitter name)"
      return ret.join "/"
    edit_link: -> "submissions.candidate_edit.basics"
    edit_data: -> 
      id:@_id
    review_requested:->
      @review_request?
    review_request_time:->
      moment(@review_request).fromNow()
    retract_confirm:(inst)->inst.show_confirm_unrequest_review.get()
  tmpl.instance_helpers helpers
  
  tmpl.onCreated ->
     @show_confirm_unrequest_review = new ReactiveVar(false)
  tmpl.events
    'click .do-trash':(e,inst)->
      debugger 
      Submissions.update _.pick(this, ['_id'] ),
          $set:
            trashed:true
            draft:@draft

    'click .do-untrash': (e,inst)-> 
      Submissions.update _.pick(this, ['_id']),
          $unset:
            trashed:false
          $set:
            draft:@draft
        
    'click .do-request-review': (e,inst)->
      Submissions.update _.pick(this,['_id']),
        $set:
          draft:@draft
          review_request: new Date
    'click .do-unrequest-review': (e,inst)->
      Submissions.update _.pick(this, ['_id']),
          $unset:
            review_request:false
          $set:
            draft:@draft
      inst.show_confirm_unrequest_review.set(false)
    'click .do-confirm-unrequest-review':(e,inst)-> 
      inst.show_confirm_unrequest_review.set true 
    'click .do-unconfirm-unrequest-review': (e,inst)->
      inst.show_confirm_unrequest_review.set false
    'click .do-show-preview':(e,tmpl)->
      data= Blaze.getData(e.currentTarget)
      Modal.show 'preview_modal' , 
        template: 'preview_all'
        data: 
          data: data
      debugger


       
