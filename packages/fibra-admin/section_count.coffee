Meteor.startup ->
  counter= {}
  query=
    $or:[
        trashed:false
      ,
        trashed:
          $exists:false
      ]
  Submissions.find(query).forEach (doc)->
    if doc?.sections?
      for section in doc.sections
        unless section?.name?
          continue
        counter[section.name]?=0
        counter[section.name]++
  for section, count of counter
    Sections.update {name:section},
      $set:
        draft:true
        entries:count
