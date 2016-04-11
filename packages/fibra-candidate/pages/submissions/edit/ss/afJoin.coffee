do(tmpl= 'afJoin')

AutoForm.addInputType 'join',
  template: 'afJoin'
  isHidden: true
  valueOut: ->
    @val()
  valueConverters:
    'stringArray': AutoForm.valueConverters.stringToStringArray