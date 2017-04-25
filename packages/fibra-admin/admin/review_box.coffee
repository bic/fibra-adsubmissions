do(tmpl=Template.review_box)->
  tmpl.onCreated ->
    @submitting=new ReactiveVar()
    if Meteor.users.isAdmin Meteor.userId()
      # This is needed to ensure the applied filter does not remove on message create the review drom the subscribed dataset.
      @autorun ->
        data= Template.currentData()
        Meteor.subscribe 'filtered_submissions', {_id:data._id}
    @sending_email=new ReactiveDict()

  helpers=
    review_request_label: (inst)->
      return unless @data.review_request
      human_date: moment(@data.review_request).fromNow()
      date:@data.review_request
    action_button_text:(inst)->
      if inst.submitting.get()
        return "Submitting Review..."
      if @data.review_request
        return "Answer Request for Review"
      else
        return "Send Review Message"
    action_button_class: (inst)->
      if inst.submitting.get()
        return 'disabled'
      else
        return ''
    reviews:(inst)->
      unless @data._id
        return
      sub = Submissions.findOne(@data._id)
      sub.reviews 
    human_date:(inst, date)->
      moment(date).fromNow()
    reviewer:(inst)->
      unless @reviewer
        return
      Meteor.users.findOne(@reviewer)
    show_message_composer:(inst)->
      if @show_message_composer?
        return @show_message_composer
      else
        return true
    is_admin:->
      Meteor.users.isAdmin(Meteor.userId())
    sorted_notification_emails:->
      unless @notification_emails
        return 
      else
        debugger
        return _.sortBy @notification_emails, (notification)-> -1*notification.sent or -1*notification.error?.time
    send_email_btn_label:(inst)->
      if inst.sending_email.get(@id)
        return "Sending ..."
      else
        return "Send Email"
    send_email_btn_class:(inst)->
      if inst.sending_email.get(@id)
        return "disabled"
      else
        return ""

  tmpl.instance_helpers helpers
  tmpl.events
    'click .do-submit-review':(e,inst)->
      editor = Blaze.getView(inst.find('.wk-container')).templateInstance().editor
      now= new Date()
      mod = 
        $set:
          draft:inst.data.data.draft
          last_review:now 
        $push:
          'reviews':
            reviewer: Meteor.userId()
            text: editor.value()
            created_on: now
            id: Random.id()

      if (req= inst.data.data.review_request)?
        mod.$push.reviews.review_request_from= req
        mod.$unset=
          review_request:true
      inst.submitting.set(true)    
      Submissions.update inst.data.data._id, mod , (err,success)->
        if err
          console.error err
        else
          inst.submitting.set(false)  
          editor.value('')
    'click .do-send-review-notification':(e,inst)->
      review = Blaze.getData(e.currentTarget)
      submission = inst.data.data
      submission_title= ->
        ret= []
        ret.push @title or "(no title)"
        ret.push @brand or "(no brand)"
        ret.push @submitter_contact?.name or "(no submitter name)"
        ret.join '/'
      submission_title = submission_title.call submission
      
      subject = "Ajustari necesare pentru #{submission_title}"
      text = """
Referitor la inscrierea ta #{submission_title} (#{Meteor.absoluteUrl('submissions/candidate_edit/') + submission._id}/basics)

Pentru inscrierea din competitia "Premiile FIBRA" sunt necesare cateva ajustari:

#{review.text}

Poti citi ajustarile necesare pentru fiecare intrare si in platforma, la http://adsubmission.premiilefibra.ro/submissions/candidate_edit/all_submissions

Iti uram succes la Premiile FIBRA!

"""
      inst.sending_email.set review.id, true
      Meteor.call 'send_review_notification_email', submission._id , review.id, text, subject, (err,success)->
        inst.sending_email.set review.id, false
