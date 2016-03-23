do(tmpl=Template.form_help_block)->
  helpers = 
    failed_messages: (inst)-> 
      debugger
      msg = inst.reactiveForms.parentData.failedMessage.get()
      if msg?
        msg.split?( "\n") or [msg.message]
    success_messages: (inst)-> 
      inst.reactiveForms.parentData.successMessage.get()?.split "\n"
    invalid:(inst)->
      inst.reactiveForms.parentData.invalid.get()
    invalidCount:(inst)->
      inst.reactiveForms.parentData.getInvalidCount()
  tmpl.instance_helpers helpers
  ReactiveForms.createElement
    template:'form_help_block'

