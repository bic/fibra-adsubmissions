

share.fields=
  basics:'title,brand,client,first_implementation,promoted_products_description,submitter_contact,sections,client_contact'
  credits:'credit_contacts'
  production:'production'
  media:'media'
  more_contributors:'other_companies'
  case_presentation:'context_description,campaign_summary,target_audience,results_summary,confidential_info'
  file_upload:'files'

do(tmpl=Template._ss_base)->
  
  AutoForm.addHooks null,
    formToDoc: (doc)->
      #debugger
      _.set doc , 'draft', true
      return doc
    formToModifier:(mod) ->
      _.set mod , '$set.draft', true
      if mod.$set.files?
        mod.$set.files=_.compact mod.$set.files
      #debugger
      return mod
    docToFormModifier:(doc)->
      doc.draft= false

      return doc
      return _.omit(doc , 'draft')
    onSubmit: (insertDoc, updateDoc, currentDoc)->
      if insertDoc
        _.set insertDoc , 'draft', true
      if updateDoc
        _.set updateDoc , '$set.draft', true
      this.event.preventDefault()
      this.done()
    template: -> 'bootstrap3'

  helpers=
    form_type:->
    pick_fields: ->
      share.fields 
    base_doc: ->
      id = Router.current().params.id
      if id?
        ret = Submissions.findOne(id)
        ret.draft= false
        return ret
      else
        return
    col: (inst, args..., kwargs)->
      debugger
      if args.length
        return share.collection_for_name args[0]
      else if @collection
        return share.collection_for_name collection
    col_schema: (inst, args..., kwargs)->
      debugger
      if args.length
        col= share.collection_for_name args[0]
      else if @collection
        col= share.collection_for_name collection
      if col
        return col.simpleSchema({draft:true})
    qf_env:(inst, args... , kwargs)->
      ret = kwargs.hash
      if ret.collection
        ret.collection= join.config.collection_for_name ret.collection
      unless ret.schema?
        ret.schema= (join.config.schemas_for_collection ret.collection).filter (s)->s.selector.draft
        ret.schema= ret.schema[0].schema
      id = Router.current().params.id
      unless id?
        ret.doc = 
          draft:false
      else
        ret.doc =  Submissions.findOne(id)
        _.extend ret.doc,
            draft:false
      ret.type?=do ->
        #return "normal"
        if id? and id.length==17 #default mongoid length
          return "update"
        else
          return "insert"
      debugger
      return ret
    schema_submissions:->

  tmpl.instance_helpers(helpers)

for tmpl in ['afArrayField', 'afObjectField', 'autoForm', 'quickForm'].map((name)->Template[name])
  tmpl.onCreated ->
    @form_control_namespaces = new ReactiveDict()
###
add show/hide functionality
###
Template.afFieldInput.onRendered ->
  ns = @get('form_control_namespaces')
  if ns
    @form_control_namespaces = ns

    @autorun =>
      data= Template.currentData()
      #ctx = AutoForm.Utility.getComponentContext(data, "afFieldInput")
      schema = AutoForm.getSchemaForField(data.name)
      if schema.control_field?
        Tracker.nonreactive =>
          @autorun =>
            value = AutoForm.getFieldValue(data.name)
            ns.set( schema.control_field, value)
      if schema.controlled_by?

        for key, func of schema.controlled_by
          Tracker.nonreactive =>
            @autorun =>
              value = ns.get(key)
              func.call this,value
