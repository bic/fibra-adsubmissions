do(tmpl=Template.homePrivateSubmissions)->
  helpers= 
    submission_list:-> Submissions.find()
  tmpl.instance_helpers helpers
do(tmpl=Template.submission_link)->
  helpers=
    title: ->
      @title or "(no title set)"
    edit_link: -> "submissions.candidate_edit.basics"
    edit_data: -> 
      id:@_id
  tmpl.instance_helpers helpers
