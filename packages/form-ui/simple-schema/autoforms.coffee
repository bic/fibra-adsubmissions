_= lodash
hide_handler= person_handler= (value_cmp)->
  (value)->
    $(this.firstNode).siblings().filter('.form-control').parent('.form-group').toggle(value == value_cmp)
    #$(@find('form-control')).toggle( value == value_cmp)
SimpleSchema.extendOptions
  controlled_by: Match.Optional Object
  control_field: Match.Optional String

mixins = 
  _do_mixin:(obj,name,mixin)->
    for key,val of mixin
      if obj["#{name}#{key}"]?
        _.merge obj["#{name}#{key}"], val
      else
        obj["#{name}#{key}"]= val
    return obj
  person_role: (obj,name)->
    @_do_mixin obj, name, 
      '':
        autoform:
          template: "fibra_naked"
      '.$.role':
        autoform:
          'formgroup-class': 'col-md-6'
          #placeholder:"Role played or Job title"
          template: "bootstrap3"
      '.$.name':
        autoform:
          'formgroup-class': 'col-md-6'
          template: "bootstrap3"
  person_or_company_role :  (obj, name)->
    # add the person stuff
    @person_role obj,name

    @_do_mixin obj, name,
      'title':
        autoform:
          afObjectField:
            
            headingClass: "hidden"
      '.$.is_company':
        defaultValue:false
        autoform:
          type:"boolean-select"
          trueLabel:'company'
          falseLabel:'person'
        control_field:"is_company"
      '.$.job_title':
        #autoform:
        #  placeholder:"The Job title or role played"
        controlled_by:
          is_company: person_handler(false)
      '.$.name':
        autoform:{}
      #'.$.email':
      #  #autoform:
      #  #  placeholder: "@"
      '.$.phone':
        autoform:
          type:"tel"
          #placeholder: "+40/7..."
        controlled_by:
          is_company: person_handler(false)
      '.$.legal_identifyer':
        #autoform:
        #  placeholder: "CUI/VAT-ID/Reg. No ..."
        controlled_by:
          is_company: person_handler(true)
  company: (obj,name)->
    
    @_do_mixin obj, name,

      '.company':
        autoform:
          template:'bootstrap3'
      

    @person_role obj , "#{name}.contacts"
    @contact_person obj, "#{name}.designated_contact"

  contact_person: (obj,name)->
    @_do_mixin obj, name,
      '':
        autoform:
          explain: '(Person to contact in case of additional questions during judging. The contact should be someone who was directly involved in the campaign)'
      '.name':
        autoform:
          template: 'bootstrap3'
          'formgroup-class': 'col-md-6'
      '.job_title':
        autoform:
          template: 'bootstrap3'
          #placeholder: "Position/Function"
          'formgroup-class': 'col-md-6'
      '.email':
        autoform:
          template: 'bootstrap3'
          #placeholder: "@"
          'formgroup-class': 'col-md-6'
      '.phone':
        autoform:
          template: 'bootstrap3'
          #placeholder: "+40/755/..."
          'formgroup-class': 'col-md-6'
      

share.on_json_loaded ->
  autoform_defs = 
    submissions:
      "title":
        
        autoform:
          'formgroup-class': 'col-md-6'
          #placeholder: "Title"
      "brand":
        
        autoform:

          'formgroup-class': 'col-md-6'
          #placeholder: "The promoted Brand"
      "client":
        
        autoform:
          'formgroup-class': 'col-md-6'
          #placeholder: "Customer"
      "first_implementation":
        autoform:
          'formgroup-class': 'col-md-6'

      "promoted_products_description":
        autoform:
          'formgroup-class': 'col-md-12 clearfix'
      'sections':
        autoform:
          template: "fibra"
          afArrayField:
            showRemove:false
          explain_template: 'section_pick_explain'
      'sections.$':
        autoform:
          afObjectField:
            label:false
            tableClass: "table-condensed"
            template: "fibra_naked" #afObjectField_bootstrap3
      'sections.$.name':
        autoform:
          type:"selectize"
          placeholder: "----- select -----"
          
          #options: share.sections_list.map (x)-> 
          #  x.value= x.name
          #  return x
          options: share.grouped_selections_list
          afFormGroup:
            template:'fibra_inline'
            showRemoveBtn: true
          afFieldInput:
            template:"bootstrap3"
            selectizeOptions:
                create:false
                labelField:"value"
                valueField:"value"
                searchField:"value"
            #isReactiveOptions: true    
          #placeholder: "Select a section"
      "submitter.is_company":
        autoform:
          type:"boolean-select"
          trueLabel:'Agency'
          falseLabel:'Freelancer'
        control_field:"is_company"
      "submitter.legal_identifyer":
        #autoform:
        #  placeholder: "CUI/VAT-ID/Reg. No ..."
        controlled_by:
          is_company: person_handler(true)
      "submitter.legal_person_identifyer":
        #autoform:
        #  placeholder: "P.F/P.F.A/CNP..."
        controlled_by:
          is_company: person_handler(false)
      "submitter.agency_type":
        autoform:
          #placeholder: "Agency Type"
          type:'selectize'
          options:share.company_roles.map (x)=>{value:x}
          selectizeOptions:
            multiple:false
            
            labelField: "value"
            valueField: "value"
            searchField: "value"
            create:true
          #isReactiveOptions: true
        controlled_by:
          is_company: person_handler(true)
    
  mixins.contact_person autoform_defs.submissions, 'submitter_contact'
  mixins.contact_person autoform_defs.submissions, 'client_contact'
  _.extend autoform_defs.submissions,
    'submitter_contact':
      autoform:
        afObjectField:
          explain:"(Person to contact in case of additional questions during judging. The contact should be someone who was directly involved in the campaign)"
    'client_contact':
      autoform:
        afObjectField:
          explain: '(Person to contact in case of additional questions during judging. The contact should be someone who was directly involved in the campaign)'



  _.extend autoform_defs.submissions , 
      "files.$":
        autoform:
          afObjectField:
            headingClass: "hidden"
          explain_before:true
          explain_template: "file-upload-explain"
      "files.$.translation":
        controlled_by: 
          is_case_file: (val)->
              fg= $(this.firstNode).parents('.form-group')
              fg.toggle(val==false)

        autoform:
          type: "woofmark"
          #word_count:true
          #display_word_count:true
          #word_count_display_template:"word_count_fibra"
          placeholder:""
          #placeholder: "Translate any romanian content relevant to the jury contained in the file"
      "files.$.is_case_file":
        label:null
        control_field:"is_case_file"
        autoform:
          
          type:"boolean-radios"
          trueLabel:'Case'
          falseLabel:'Creative'
      "files.$.file_id":
        autoform: 
          afFieldInput:
            type: 'fileUpload'
            collection: 'SubmissionFiles'
            label: 'Choose file...'
            onBeforeInsert: ->
              (fileObj)->
                _.set fileObj,  ['metadata', 'owner_account'],  Meteor.userId()
                fileObj
      'credit_contacts.$':
        label: "contact"
        autoform:
          afObjectInput: ->  
            type:"hidden"
 
  mixins.person_role autoform_defs.submissions, 'credit_contacts'
  mixins.company autoform_defs.submissions, 'production'

  #mixins.contact_person autoform_defs.submissions, 'production.designated_contact'

  mixins.company autoform_defs.submissions, 'media'
  #mixins.contact_person autoform_defs.submissions, 'media.designated_contact'
  mixins.company autoform_defs.submissions, 'other_companies.$'
  mixins.contact_person autoform_defs.submissions, 'other_companies.$.designated_contact'
  _.extend autoform_defs.submissions , 
      'other_companies':
        autoform:
          headerClass: 'hidden'
      'other_companies.$.role':
        autoform:
          template:'bootstrap3'
      #promoted_products_description:
      #  autoform:
      #    type:'woofmark'
      context_description:
        autoform:
          type:'woofmark'
          placeholder:""
          word_count:true
          display_word_count:true
          word_count_display_template:"word_count_fibra"
      campaign_summary:
        autoform:
          type:'woofmark'
          placeholder:""
          word_count:true
          display_word_count:true
          word_count_display_template:"word_count_fibra"
      target_audience:
        autoform:
          type:'woofmark'
          placeholder:""
          word_count:true
          display_word_count:true
          word_count_display_template:"word_count_fibra"
      media_appearance:
        autoform:
          type:'woofmark'
          placeholder:""
          word_count:true
          display_word_count:true
          word_count_display_template:"word_count_fibra"
      results_summary:
        autoform:
          type:'woofmark'
          placeholder:""
          word_count:true
          display_word_count:true
          word_count_display_template:"word_count_fibra"
      confidential_info:
        autoform:
          type:'woofmark'
          placeholder:""
          word_count:true
          display_word_count:true
          word_count_display_template:"word_count_fibra"

  #for key , val of autoform_defs
  #  _.set val, ['autoform', 'afFormGroup', 'class'] , 'col-sm-6'

  
  share.merge_schema autoform_defs
    





       
  other = 
    submissions:
      #promoted_products_description:
      #  placeholder: "Enter here a short description of what you created"
      #submitter_id:
      #  placeholder: "Legal Entity"
      
      #context_description:
      #  placeholder: "In what circumstantions did you become creative"
      #campaign_summary:
      #  placeholder: "objectives, strategy, creative idea and implementation"
      #target_audience:
      # placeholder: "Core audience & more"
      #results_summary:
      #  placeholder: "Outcome & impact"
      #confidential_info:
      #  placeholder: "For juries eyes only!"
      "credit_contacts.$.role":
        
        autocomplete:
          type:'horsey'
          suggestions: share.job_titles
          allow_custom: true
      "production.contacts.$.role":
        #placeholder:"The Job title or role played"
        autocomplete:
          type:'horsey'
          suggestions: share.job_titles
          allow_custom: true
      "media.contacts.$.role":
        #placeholder:"The Job title or role played"
        autocomplete:
          type:'horsey'
          suggestions: share.job_titles
          allow_custom: true   
      #"other_companies.$.role":
      #  #placeholder: "Function of the company within the project"
      #  ###autocomplete:
      #    type:"horsey"
      #    suggestions: company_roles
      #    allow_custom: true
      #  ###     
      "files.$.is_case_file":
        switch:
          onText: "Case File"
          offText: "Campaign File"


    