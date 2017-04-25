_= lodash
Meteor.methods
  send_review_notification_email: (submission_id, review_id, text, subject)->
    
    err= ""
    unless Meteor.users.isAdmin @userId
      err+= "Only Admin users may send emails"
    unless _.isString(submission_id) and submission_id.length
      err = "send_review_notification_email: #{err} submission id is required!"
    unless _.isString(text) and text.length
      err = "send_review_notification_email: #{err} submission text is required!"
    unless _.isString(subject) and subject.length
      err = "send_review_notification_email: #{err} submissions subject is required!"
    if err.length
      throw new Meteor.Error (err)
    unless @isSimulation
      submission= Submissions.findOne submission_id
      user = Meteor.users.findOne submission.owner_account
      current_user=  Meteor.users.findOne this.userId
      to = {}
      if submission?.submitter_contact?.email
        to[submission.submitter_contact.email]= submission.submitter_contact.email
        if submission.submitter_contact?.name
          to[submission.submitter_contact.email] = "#{submission.submitter_contact.name} <#{to[submission.submitter_contact.email]}>"
      if user?.profile?.email? and not to[user.profile.email]?
        if user.profile.name
          to[user.profile.email] = "#{user.profile.name} <#{user.profile.email}>"
      this.unblock()
      opt =
        from:  "#{current_user.profile.name} <#{current_user.profile.email}>"
        to: _.values to
        cc: "Fibra Adsubmission Support <contact@iqads.ro>"
        bcc: "#{current_user.profile.name} <#{current_user.profile.email}>"
        
        text:text
        subject: subject
      opt.replyTo= [
        opt.from,
        opt.cc
        ]
      try
        Email.send opt
      catch e
        opt.error = 
          msg: "Error sending  email:" + e.toString()
          time: new Date()
      unless opt.error
        opt.sent= new Date()
      console.log  { _id: submission_id , 'reviews.id': review_id}, 
          $push:
            'reviews.$.notification_emails': opt
        ,
          validate:false
      selector= 
        _id: submission_id
        'reviews.id': review_id
        draft:submission.draft
      mod = 
        $push:
          'reviews.$.notification_emails': opt
      options=
        validate:false
      Submissions.direct.update selector, mod , options 
          
        
          
      return 


