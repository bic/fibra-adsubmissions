router_target = null
AutoForm.addHooks null,
    onSuccess: (formType,result)->
      debugger
      if router_target
        Router.go router_target.replace "/INSERT_ID/", "/#{@docId}/"


do(tmpl=Template.ss_submit_btn)->
  tmpl.onCreated ->
    @target_name=new ReactiveVar()
    if @data.target
      router_target= @data.target
    else
      @autorun (c)=>
        path= Router.current().location.get().path
        Tracker.afterFlush =>
          nextelm = $('.side-bar-item.active').next()
          title = nextelm.find('.item-title')
          @target_name.set title.text()
          id = Router.current().params.id
          link = nextelm.find('a').attr('href')
          router_target = link.replace /\/new\//, "/INSERT_ID/"
  tmpl.onDestroyed ->
    router_target= null
  

  tmpl.instance_helpers 
    next_name: ->
      ## this gets the name from the next entry in the sidebar
      name= Template.instance().target_name.get()
      if name?
        return "Proceed to #{name}"
      else
        return "Submit"
  tmpl.events 
    'click button':(e,tmpl)->
      debugger
      form = $('form:first')
      if 'target' of tmpl.data
        router_target = tmpl.data.target
      unless form.has(e.currentTarget).length
        form.trigger('submit')
