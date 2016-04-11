_= lodash
form_ui=
  console:console

{checkNpmVersions}= require 'meteor/tmeasday:check-npm-versions' 
checkNpmVersions 
  'mongo-dot-notation':'1.0.5'

dot = require('mongo-dot-notation');


class FormUIError extends Error
  constructor:(@message,@original)->
    if Meteor.isClient
      if inst= Template.instance()
        @tmpl= inst.view.name
    if @original instanceof Error
      @message = @_build_msg()
      @stack=@original.stack
      @name=@original.name 
    unless _.isString @msg
      @original=@msg
      delete @msg
  _build_msg: ->
    ret = ""
    if @tmpl
      ret += "#{@tmpl}: "
    ret += @message
    if @original
      ret += "\nOriginal Error:\n" + @original.message


_.extend form_ui, 
  except:(args...)->
    throw new FormUIError args...
  err:(args...)->
    form_ui.console.error new FormUIError(args...).toString()
  log:(args...)->
    form_ui.console.log new FormUIError(args...).toString()
  dbg:(args...)->
    form_ui.console.debug new FormUIError(args...).toString()
  inf:(args...)->
    form_ui.console.info new FormUIError(args...).toString()
  
  flat_set_mod: (value)->
    dot.flatten _.cloneDeepWith value, (val) ->
      if _.isArray(val)
        return _.zipObject(_.range(val.length), val)
      return
  ###
    datapath compiles a schema path like `x.$.f`
    into a datapath like `["x",1,"f"]`
    @param view: the view for which to find the data path
    @param reactive: dependencies are added to the views from which the path is taken _defaut: `false`_
    @returns the object data path in array form [field, index, fiels] ready to use with `_.get`
  ###
  parent_form_instance:(view)->
    ret= null
    share.each_parent_template view, (inst)->
      if inst.view.name.endsWith 'bs_form'
        ret= inst
        return false
      return
    if ret?
      return ret
    else
      return
  ###
  returns the root form instance
  ###
  root_form_instance:(view)->
    ret = form_ui.parent_form_instance (view)
    unless ret?
      return
    console.log ret
    while ret.reactiveForms.parent_form?
      ret= ret.reactiveForms.parent_form
    return ret
  data_path:(view, reactive)->
    view?=Blaze.getView() 
    schema_path= null
    ###
      for debugging
      path= []
    ###
    data_path= []
    while view  
      if inst= view.templateInstance?()
        #ignore non-template views


        if inst.reactiveForms and inst.reactiveForms.field
          # also ignore non reactiveForms templates

          if not schema_path?
            schema_path= inst.reactiveForms.field.split "."
            default_path= inst.reactiveForms.field.split "."
            default_path_view= view
          if default_path.length > schema_path.length
            default_path.splice(schema_path.length, default_path.length)
          while schema_path.length
            if schema_path[-1..][0] == '$'
              if default_path[-1..][0]!= '$'
                data_path.push default_path[-1..][0]
                if reactive
                  ## TODO: add some more care that we actually only depend on `field` of `depVar`
                  Blaze.getView(default_path_view , 'with').dataVar.dep.depend()
              else if inst.data.index?
                data_path.push inst.data.index
                if reactive
                  ## TODO: add some more care that we actually only depend on `field` of `depVar`
                  Blaze.getView(view , 'with').dataVar.dep.depend()
              else
                form_ui.except "cannot find the last index in schema path #{(schema_path[0...-1])}[this index]"
            else
              data_path.push schema_path[-1..][0]
            if _.isEqual schema_path , data_path
              # this means we have taken all parts down to this field
              stop= true
            schema_path.splice schema_path.length-1, 1
            default_path.splice default_path.length-1,1
            break if stop
          default_path= inst.reactiveForms.field.split "."

          if reactive
            default_path_view = view
          ###
          for debugging
          path.push
            field: inst.data.field
            idx: inst.data.idx
            view:view
          ###
          unless schema_path.length
            # found what i was lookin for so stop now!
            break
      view = view.originalParentView or view.parentView
    return data_path.reverse()
  company_roles:share.company_roles= [ 
    "Creative Agency/Full-service Agency",
    "Digital Agency",
    "Media Agency"
    "PR Agency"
    "BTL Agency"
    "Branding Agency"
    "Production Company"
  ]









