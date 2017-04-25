_= lodash
vat_options=[
      label: "VAT payer - Plătitor TVA"
      value:"1" 
    ,
      label: "VAT exempt - Neplătitor TVA"
      value:"0"
  ]
share.user_settings =
  schema_def:
    draft:
      type:Boolean
      optional:true
    company:
      type:Object
    'company.cif':
      type:String
      custom: ->
        debugger
        sib=this.siblingField('country')
        if sib.isSet== false or sib.value=='ro'
          unless form_ui.validare_cif @value
            return 'cui_not_valid'
        return
    "company.name":
      label: "Company Name"
      type:String
    "company.country":
      label: "Country"
      type: String
      autoform:
        type: 'select'
        options: ->
          ret= [
            label:"Romanian Company"
            value:'ro'
          ,
            label: "Other Country"
            value: 'other'
          ]
          
          debugger
          val=  Tracker.nonreactive ->
            AutoForm.getFieldValue('company.country')
          val?='ro'
          
          for opt in ret
            if opt.value == val
              opt.selected= true
          return ret
      
    "company.vat":
      label: "VAT Status"
      type:String
      autoform:
        group:'invoice'
        type:"select"
        options:->
          #val=  Tracker.nonreactive ->
          val= AutoForm.getFieldValue('company.vat')
          ret = _.cloneDeep vat_options
          #val?='1'
          if val?
            for opt in ret
              if opt.value==val
                console.log("set value to #{val}")
                opt.selected= true
          return ret
    "company.address":
      label:"Street/No"
      optional:true
      type:String
    "company.city":
      label:"City"
      optional:true
      type:String
    "company.zip":
      optional:true
      type:String
AutoForm.hooks
  invoice_form:
    onSubmit: (doc)->
      debugger
      @ss.clean(doc)
      
      Meteor.users.update Meteor.userId(),
        $set:
          'profile.company': doc.company

      @done()
      @currentDoc = doc
      #AutoForm._forceResetFormValues('invoice_form')
      @event.preventDefault()

      
do(tmpl= Template.invoice_data) ->
  form_id= 'invoice_form'
  tmpl.onCreated ->
    @searching=new ReactiveVar(false, _.isEqual )
    @schema=new SimpleSchema share.user_settings.schema_def
    @valid_cif=new ReactiveVar()
    @show_extended_view= new ReactiveVar(true)
    
    @current_doc= new ReactiveVar
    doc= null
    @autorun =>
      user_entry= Meteor.users.findOne()
      doc = user_entry?.profile
      unless doc.company?
        @show_extended_view.set(false)
      doc ?= {}
      @schema.clean doc
      @current_doc.set(doc)
    @current_cif= new ReactiveVar(doc.company?.cif)
    @country = new ReactiveVar
    @autorun =>
      @country.set country= AutoForm.getFieldValue('company.country',form_id)
      if country? and country!='ro'
        #console.error "country: #{country}"
        #Only allow hiding field for romanian companies
        @show_extended_view.set(true)
  tmpl.onRendered ->
    @autorun (c)=>

      cif= @current_cif.get()
      country=  @country.get() 
      unless c.firstRun
        
        if country == 'ro' and cif? and form_ui.validare_cif cif
          @valid_cif.set true

          current_result = Tracker.nonreactive =>
            @searching.get()
          unless current_result== true 
            @searching.set true
            #console.error "searching #{cif}"
            Meteor.call 'ro_company_info', cif, (error, company_data)=>
              if error
                console.error "error searching for cif=#{cif}:", error
              else if company_data
                @searching.set  @schema.clean 
                  company: company_data 
              else @searching.set false
        else if cif? and country == 'ro'
          @valid_cif.set(false)
        else
          @valid_cif.set(null)
    @autorun (c)=>
      # fill the form for the first time
      if @show_extended_view.get() == false
        if _.isObject result=@searching.get()
          @current_doc.set result
          @searching.set false
          @show_extended_view.set true  
  helpers=
    
    invalid_cif: (inst)-> inst.valid_cif.get()==false
    valid_cif: (inst)-> inst.valid_cif.get()==true
     
    searching_company_info:(inst)->
      return inst.searching.get() == true
    have_company_info_search_result:(inst)->
      _.isObject inst.searching.get()
    hide_classes: (inst)->
      if inst.show_extended_view.get()
        return ""
      else
        return "hide"
    replacement:(inst)->
      ret = inst.searching.get()
      if _.isObject(ret)
        return ret.company
      else
        return false
    invoice_ctx: (inst)->
      ret=
        schema : inst.schema
        doc : inst.current_doc.get()
        id: form_id
        validation: 'keyup'
        type:"normal"
        preserveForm: 'false'

  tmpl.instance_helpers helpers
  tmpl.events
    "keyup input[name='company.cif'],change input[name='company.cif']": (e,tmpl)->
      tmpl.current_cif.set(AutoForm.getFieldValue('company.cif', form_id))
    'click .do-ignore':(e,tmpl)->
      a= AutoForm
      tmpl.searching.set false
    'click .do-replace':(e,tmpl)->
      tmpl.current_doc.set(tmpl.searching.get())
      tmpl.searching.set false
    'click .do-remove':(e,tmpl)->
      Meteor.users.update Meteor.userId(), 
        $unset:
          'profile.company':1
      tmpl.show_extended_view.set( false)
do(tmpl=Template.invoice_data_dl)->
  helpers=
    vat_to_text:->
      ret= vat_options.filter (opt)=> opt.value==@vat
      if ret.length
        return ret[0].label
      else
        return "N/A"
  tmpl.helpers helpers
      








