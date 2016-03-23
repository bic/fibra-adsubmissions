
do (tmpl= Template.long_contact_details)->
  tmpl.onCreated ->
    @is_company = new ReactiveVar(false)

  tmpl.instance_helpers
    is_company: (inst)->
      inst.is_company.get()
    is_company_ref: (inst)-> inst.is_company

do(tmpl= Template._form_page_template_base)->
  helpers =
    draft_selector: ->
      draft:true
    non_draft_selector:->
      draft:false
    save_as_draft_action: ->
      (elm,callbacks,changed, orig)->
        debugger
        unless "draft" of this
          draft_was_not_defined= true
        else
          orig_draft = @draft
        @draft=true

        wrapper= (func)=>
          ->
            if draft_was_not_defined
              delete @draft
            else
              @draft=orig_draft
            return func.apply this, arguments


        callbacks_wrap = {}
        for key in "success,failed,reset".split(',')
          callbacks_wrap[key]= wrapper callbacks[key]  
        orig.call this, elm,callbacks_wrap,changed
        
  tmpl.onCreated ->
    @autorun (c)=>
      id = @id.get()
      unless c.firstRun
        router= Router.current()
        router.setParams _.extend router.params, 
            id:id

  Meteor.startup ->
    helpers.schemas= Schemas
    tmpl.helpers helpers

do(tmpl= Template.submit_continue_btn)->
  tmpl.onCreated ->
    @target_name= new ReactiveVar()
    @autorun (c)=>
      if Router.current().isReady()
        path= Router.current().location.get().path
        Tracker.afterFlush =>
          nextelm = $('.side-bar-item.active').next()
          link = nextelm.find('a').attr('href')
          if link?
            ## set the success action to continue
            registration = @reactiveForms.parentData.templateInstance.on_success ->
              Router.go link
              #and only run once
              registration.remove()
          title = $('.side-bar-item.active').next().find('.item-title')
          @target_name.set title.text()

  tmpl.instance_helpers 
    next_name: ->
      ## this gets the name from the next entry in the sidebar
      name= Template.instance().target_name.get()
      if name?
        return "Proceed to #{name}"
      else
        return "Submit"  
    classes:(inst)->
      if inst.reactiveForms.parentData.invalid.get()
        return "btn-default"
      else
        return "btn-primary"

  tmpl.events
    "click .btn.submit-partial":(e, t) ->
      debugger
      #default handling should be just fine
      return
      #return
      
      #submit first form
      form_inst= Blaze.findTemplateInstances('bs_form')[0]
      form_inst.reactiveForms.submit()
      e.preventDefault()
      next= $('.side-bar-item.active').next().find('a').attr('href')
      Router.go('next')
      #if next?
      #delay the router go until validation succeeded
      #Router.go("submissions.candidate_edit");
  ReactiveForms.createElement
    template: 'submit_continue_btn'