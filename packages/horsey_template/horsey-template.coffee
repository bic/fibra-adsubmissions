do (tmpl= Template.horsey_template)->
  tmpl.onRendered ->
    debugger
    horsey @find('input'),
      suggestions:(value, done)->
        debugger
        done ['a', 'b', 'c']
      