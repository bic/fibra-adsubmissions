_=lodash
glob= this
Meteor.startup ->
  if Meteor.isServer
    #Kadira.connect('KEtvrSznaGkeQGpt8', '96284784-00d4-4e1b-a23c-574d24c369af');
    Meteor.publishComposite 'submissions', join.publish_composite_query 'submissions', 
      
      find:(id)->
        check id , Match.Optional Match.OneOf String, [String]
        if _.isArray id
          ret = 
            _id:
              $in: id
        else if id?
          ret=
            _id:id
        else
          ret= {}
        ret.owner_account= @userId
        return Submissions.find(ret)
    Meteor.publish 'submission_files', ->
        return SubmissionFiles.find({'metadata.owner_account':@userId});
    d= (b)->
      console.log "deny: #{b}"
      return b

    a= (b)->
      console.log "allow: #{b}"
      return b
    SubmissionFiles.allow (userId, doc)->
      insert: (userId, doc)->
        unless doc.owner_account?
          return true
        else
          a userId==doc.metadata?.owner_account
      update: (userId,doc)->
           userId==doc.metadata?.owner_account
      remove: (userId, doc)->
           userId==doc.metadata?.owner_account
    SubmissionFiles.allow (userId, doc)->
      insert: (userId, doc)->
           Users.isInRoles userId, ["admin"]
      update: (userId,doc)->
           Users.isInRoles userId, ["admin"]
      remove: (userId, doc)->
           Users.isInRoles userId, ["admin"]
    SubmissionFiles.deny 
      insert: (userId, doc)->
        doc.metadata?={}
        doc.metadata.owner_account?=userId
        if doc._id?
          is_admin = Users.isInRoles userId, ["admin"]
          if is_admin
            return false
          console.log doc.metadata
          return d doc.metadata.owner_account != userId
        else
          doc.metadata.owner_account = userId

          return false
      update: (userId,doc)->
        is_admin = Users.isInRoles userId, ["admin"]
        if is_admin
          return  false
        return doc.metadata?.owner_account != userId
      remove: (userId, doc)->
        is_admin = Users.isInRoles userId, ["admin"]
        if is_admin
          return false
        return doc.metadata?.owner_account != userId
    #Meteor.publish 'Categories', ->
    #  Categories.find()
    #Meteor.publish 'Sections', ->
    #  Sections.find()


  else
    #client code
    controllers = _.pick glob , "Basics,Credits,Media,OtherContributors,Presentation,SubmissionCredits,Production,FilesUpload,AllSubmissions,UserSettingsProfileController,Preview".split(',').map (name)->"SubmissionsCandidateEdit#{name}Controller"
    _.extend controllers, 
      HomePrivateController: HomePrivateController
    #console.log "installing Subscriptions on: #{_.keys controllers}"
    for key, controller of controllers
      controller::onSubscribe ->
        return [
          Meteor.subscribe 'submissions'
          Meteor.subscribe 'Categories'
          Meteor.subscribe 'Sections'
          Meteor.subscribe 'Contacts'
          Meteor.subscribe 'submission_files'
          if this.params.id and Meteor.users.isAdmin(Meteor.userId())
            #debugger
            Meteor.subscribe 'admin_submissions', this.params.id
          
          {
            ready:->
              #debugger
              app_json.isReady()
          }
        ]
    JurySubmissionsController::onSubscribe ->
      return [
        Meteor.subscribe 'Sections'
        Meteor.subscribe 'Categories'
        Meteor.subscribe 'stats'
        Meteor.subscribe 'Tags'
         
      ]

