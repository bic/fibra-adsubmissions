_=lodash
do(tmpl=Template.submitting_entity)->
  form_id= "submitting_entity"
  schema= new SimpleSchema share.submitting_entity.schema_def


  hook= {}
  hook[form_id]=
    onSubmit: (doc)->
      schema.clean(doc)
      if doc.draft?
        delete doc.draft
      mod = 
        $set: _.mapKeys doc , (val,key)->"profile.#{key}"
      debugger

      Meteor.users.update Meteor.userId(), mod
      @currentDoc = doc
      @event.preventDefault()
      @done()

  AutoForm.hooks hook


  
  tmpl.onCreated ->
    
    @doc=  new ReactiveVar
    @autorun => 
      user_doc= Meteor.users.findOne(Meteor.userId()).profile
      schema.clean(user_doc)
      @doc.set(user_doc)
  helpers=
    form_ctx:(inst)->

      schema:schema
      doc: inst.doc.get()
      id:form_id
  tmpl.instance_helpers helpers