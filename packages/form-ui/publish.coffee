_=lodash

glob=this

publish_all_queries=
  Sections:{}
  Categories:{}
  default: ->
    owner_account:@userId



Meteor.startup ->
  for key, val of Schemas

    Meteor.publish key, do(key=key)-> 
      console.log "Publishing #{key}"
      query= publish_all_queries[key] or publish_all_queries.default
      if _.isFunction query
        query= query.call this
      -> glob[key].find(query)
  
  submission_col = share.collection_for_name 'submissions'
  Meteor.publishComposite 'composite' , join.publish_composite_query 'submissions',
    find:()->
      submission_col.find {},
        owner_account: @userId

    
  