
do(tmpl=Template.UserSettingsProfileEditForm)->
  helpers=
    is_juror:-> Users.isInRole 'juror'
  tmpl.instance_helpers helpers

