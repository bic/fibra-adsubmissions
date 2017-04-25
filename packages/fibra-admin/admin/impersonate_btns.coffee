do(tmpl= Template.unimpersonate_btn)->
  tmpl.events
    'click .do-unimpersonate':(e,tmpl)->
      Impersonate.undo (err,success)->
        debugger
        unless err
          if target= Session.get 'impersonate_return_url'
            Session.set('impersonate_return_url', undefined)
            Tracker.afterFlush ->
              Router.go target
            

do(tmpl=Template.impersonate_btn)->
  tmpl.events
    'click.do_impersonate':(e,inst)->
      debugger
      data = Blaze.getData(e.currentTarget)
      #need to store go_url locally asa data context may disappear
      go_url= data.go_url
      if data.return_url?
        if data.return_url
          Session.set 'impersonate_return_url', data.return_url
      else
        Session.set 'impersonate_return_url', Router.current().url
      Impersonate.do data.user_id , (err,success)->
        unless err
          if go_url
            Tracker.afterFlush ->
              Router.go go_url
