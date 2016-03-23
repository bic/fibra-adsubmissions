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
        return SubmissionFiles.find({});

  else
    #client code
    controllers = _.pick glob , "Basics,Credits,Media,Other_contributors,Presentation,Submission_credits,FilesUpload".split(',').map (name)->"SubmissionsCandidateEdit#{name}Controller"
    _.extend controllers, 
      HomePrivateController: HomePrivateController
      HomePrivateSubmissionsController:HomePrivateSubmissionsController
      HomePrivateWelcomeController:HomePrivateWelcomeController
    for key, controller of controllers
      controller::onSubscribe ->
        Meteor.subscribe 'submissions'
        Meteor.subscribe 'Categoried'
        Meteor.subscribe 'Sections'
        Meteor.subscribe 'submission_files'

