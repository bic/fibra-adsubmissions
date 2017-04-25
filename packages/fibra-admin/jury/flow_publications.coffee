_= lodash
Meteor.publishComposite 'jury_submission_publication' , (filter,options, pagination)->
  unless Users.isAdminOrInRole(@userId , 'juror')
    return
  
  ###if Users.isInRole 'juror'
    if _.isObject filter
      if filter.$and
        filter.$and.push 
          owner_account: @userId
      else
        filter=
          $and:[ {owner_account: @userId} , filter]
    else
      filter= 
        owner_account:@userId
  ###
  ret=
    find:->
      #console.log "filter" , filter
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
            mod=
              submission:user_doc._id
            unless Users.isAdmin @userId
              mod.createdBy=@userId
            ret= Evaluations.find mod
            return ret 
          else
            return

      ]



Meteor.startup ->
  Stats.remove({})
  get_initial=(juror_id)->
    ret= share.jurors.filter ( jur)-> jur.id==juror_id
    return ret[0]?.initial 
  avg= (prev,obj, prop)->
    if obj[prop]? and _.isFinite(num= parseFloat obj[prop])
      prev[prop]?=  
        sum:0
        count:0
      prev[prop].sum+= num
      prev[prop].count++
      if prev[prop].count
        prev[prop].avg = prev[prop].sum / prev[prop].count
      prev.by_juror?={}
      prev.by_juror[get_initial obj.createdBy] ?={}
      prev.by_juror[get_initial obj.createdBy][prop] = num
  update_stats=(doc)->
    cur = Evaluations.find
      #createdBy:$in _.map(share.jurors, 'id')
      section: doc.section
      submission: doc.submission
    section= Sections.findOne
      name:doc.section
    stat=
      section: doc.section
      section_id:section._id
      submission: doc.submission
    _.extend stat, cur.fetch().reduce (stat, e)->
        avg stat, doc, 'originality'
        avg stat, doc, 'context'
        avg stat, doc, 'execution'
        return stat
      ,
        {}
    overall = 
      sum:0
      count:0
    for val in _.values _.pick stat, ['originality', 'context', 'execution']
      if val.count
        overall.sum+=val.avg
        overall.count++
    if overall.count
      overall.avg=
        overall.sum/overall.count
      stat.overall = overall
    for  initial, juror_stat of stat.by_juror
      overall=
        sum:0
        count:0
      for val in _.values _.pick juror_stat, ['originality', 'context', 'execution']
        overall.sum+=val
        overall.count++
      if overall.count
        overall.avg= overall.sum/overall.count
        juror_stat.overall= overall

    prev = Stats.findOne
      section:stat.section
      submission: stat.submission
    console.log 'stats' , stat
    if prev?
      console.log "updating stats (_id:#{prev._id})" , stat
      Stats.update prev._id , stat
    else
       console.log 'insertin stats' , stat
      Stats.insert stat

  ev_query = 
    createdBy: 
      $in: _.map(share.jurors, 'id')
  console.log("searching for juror evals with", ev_query)
  Evaluations.find(ev_query).observe
    added:(doc)-> 
      #console.log('added:' , doc)
      update_stats(doc)
    changed:(new_doc, old_doc)->
      update_stats(new_doc)
      console.log('updated' , new_doc._id)
    removed:(doc)->update_stats(doc)
  Meteor.publish 'stats', ->
    unless Users.isAdminOrInRole(@userId,'juror')
      console.error "stats subscription not permitted for user:" , @userId
      @ready()
      return
    else
      cur = Stats.find()
      console.log "subscribing to stats (count=#{cur.count()} for user #{@userId}"
    return cur
