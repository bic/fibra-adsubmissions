_=lodash

glob=this
Meteor.startup ->
  for key, val of Schemas

    Meteor.publish key, do(key=key)-> 
      console.log "Publishing #{key}"
      -> glob[key].find({})
  
  submission_col = share.collection_for_name 'submissions'
  Meteor.publishComposite 'composite' , join.publish_composite_query 'submissions',
    find:()->
      submission_col.find {},
        owner_account: @userId

    
  