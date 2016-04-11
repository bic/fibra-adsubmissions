do(tmpl= Template.submissionsCandidateEditPreview)->
  helpers= {}
  tmpl.onRendered ->
    user_doc= Meteor.users.findOne Meteor.userId()
    if (not user_doc?.profile?.hints?.preview_next?) or user_doc.profile.hints.preview_next
      Modal.show 'whats_next_preview'
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom "_ss_base" 
  tmpl.inheritsHooksFrom '_ss_base'
  tmpl.events
    'click .do-whats-next':(e,tmpl)->
      Modal.show 'whats_next_preview'
do(tmpl= Template.whats_next_preview )->
  tmpl.helpers
    checkbox_dyn:(inst)->
        user_doc= Meteor.users.findOne Meteor.userId() 
        ret={}
        if user_doc?.profile?.hints?.preview_next?
          if user_doc.profile.hints.preview_next
            ret.checked= "checked"
        else
          ret.checked= "checked"
        return ret

  tmpl.events
    'change input.remind-again':(e,tmpl)->
      debugger
      Meteor.users.update Meteor.userId(),
        $set:
          'profile.hints.preview_next':e.currentTarget.checked