do(tmpl=Template.presentation_display)->
  helpers={}
  tmpl.instance_helpers helpers
  tmpl.inheritsHelpersFrom '_display_base'
  tmpl.inheritsHooksFrom '_display_base'
  tmpl.inheritsEventsFrom '_display_base'