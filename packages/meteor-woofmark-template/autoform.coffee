#_= lodash 
if (AutoForm = Package['aldeed:autoform']?.AutoForm)
  ###
  accepts two arguments: name and options. The name argument defines the string that will need to be used as the value of the type 
  attribute for afFieldInput. The options argument is an object with some of the following properties:
  ###
  AutoForm.addInputType 'woofmark', 
    ###
    Optional. A function that adjusts the initial value of the field, which is then available in your template as this.value. 
    You could use this, for example, to change a Date object to a string representing the date. 
    You could also use a helper in your template to achieve the same result.
    


    ###
    valueIn: (val)->
      debugger
      return val


    ###
    Required. The name of the template to use, which you've defined in a .html file.
    ###
    template: 'woofmark'
    ###
     Required. A function that AutoForm calls when it wants to know what the current value stored in your widget is. 
     In this function, this is the jQuery object representing the element that has the data-schema-key attribute in your custom template. 
     So, for example, in a simple case your valueOut function might just do return this.val().

    ###
    valueOut: ->
      obj= woofmark.find(this[0])
      if obj?
        return obj.value()
      else 
        return
    ###
    Optional. An object that defines converters for one or more schema types. 
    Generally you will use valueOut to return a value for the most common or logical schema type, 
    and then define one or more converter functions here. The converters receive the valueOut value as an argument and should then 
    return either the same value or a type converted/adjusted variation of it. 
    
    The possible converter keys are: "string", "stringArray", "number", "numberArray", "boolean", "booleanArray", "date", and "dateArray". 
    Refer to the built-in type definitions for examples.
    ###
    #valueConverters: ->
    #  debugger

    ###
     Optional. A function that adjusts the context object that your custom template receives. That is, this function accepts an object argument, potentially modifies it, and then returns it. That returned object then becomes this in your custom template. If you need access to attributes of the parent autoForm in this function, use AutoForm.getCurrentDataForForm() to get them.

    ###
    contextAdjust:(ctx)->
      debugger
      woof_args= share.pick_woofmark_options ctx.atts
      tmpl_args= share.pick_template_options ctx.atts
      assigned_keys = _.intersection _.keys(ctx.atts) , [_.keys(woof_args)...,_.keys(tmpl_args)...]
      _.extend ctx, _.omit ctx.atts, assigned_keys
      _.extend ctx, _.pick(woof_args, assigned_keys), _.pick(tmpl_args, assigned_keys) , ctx.attrs

      return _.omit(ctx, 'atts')
do(tmpl=Template.woofmark)->
  tmpl.onCreated ->
    debugger
  tmpl.onRendered ->
    debugger
