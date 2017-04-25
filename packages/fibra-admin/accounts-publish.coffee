
Meteor.publishComposite 'accounts', ->
  find:->
    unless Users.isAdmin(@userId)
      this.ready()
      return
    cur =  Users.find()
  children:[
    find:(user_doc)->
      Submissions.find
        owner_account:user_doc._id
  ]
Meteor.publishComposite 'filtered_submissions' , (filter,options)->
  unless Users.isAdmin(@userId)
    return
  else
    ret=
      find:->
        Submissions.find filter, options
      children:
        [
          find:(user_doc)->
            if user_doc.files?
              SubmissionFiles.find
                _id:
                  $in: user_doc.files.map (file)->file?.file_id  
        ,
          find:(user_doc)->
            Meteor.users.find
              _id:user_doc.owner_account
        , 
          find:(user_doc)->
            if Users.isAdminOrInRole( @userId,'juror')
              ret= Evaluations.find
                submission:user_doc._id
              return ret 
            else
              return
  
        ]
