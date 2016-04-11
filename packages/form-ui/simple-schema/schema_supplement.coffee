_= lodash
share.schema=
  field:
    class FieldQuery
      constructor:(@schema)->
      choices:(schema=@schema)->schema?.input_spec?.autocomlpete?.choices
      has_custom_choice:(schema=@schema)-> schema?.input_spec?.autocomlpete?.allow_custom
      has_word_count:(schema=@schema)-> schema?.minWordCount? or schema?.maxWordCount?
      min_words:(schema=@schema)-> schema?.minWordCount
      max_words:(schema=@schema)-> schema?.maxWordCount
      placeholder:(schema=@schema)-> schema?.input_spec?.placeholder
      info:(schema=@schema)->schema?.input_spec?.info
      label:(schema=@schema)->schema?.label
      input_spec:(schema=@schema)->schema?.input_spec

share.each_collection
remove_blackboxes = (json)->
  for collection_def in json.collections
    c = share.collection_for_name collection_def.name
    unless c
      console.error "Could not find Collection for name #{collection_def.name}"
      continue
    if schema= c.simpleSchema?() # might be a FS.Collection as well
      schema = schema.schema()
      if  _.isString(schema.name) and schema.name.length && schema.name != c.name
        
        console.error "Schema name for collection #{c.name} differs from schema name#{ schema.name}"
      else
        for key, val of schema
          if val.blackbox
            delete val.blackbox
  share.replace_schema schema, collection_def.name




share.on_json_loaded = (func)->
  Meteor.startup ->
    Tracker.autorun (c)->
      json = app_json.get()
      if json?
        c.stop()
        func()
# only make this available on startup, because no collections are defined before that time
share.on_json_loaded ()=>
  share.collection_for_name= _.memoize (name)=>
    for key,val of this
      if val instanceof Meteor.Collection
        if Meteor.isServer
          col_name = val._name
        else
          col_name =val._collection.name
        if col_name==name 
          return val
      else if Package["cfs:base-package"]?.FS?.Collection   and val instanceof  Package["cfs:base-package"]?.FS?.Collection and val.name==name
        #file collection
        return val     
     
    return null
  
  remove_blackboxes(app_json.application)       

   


  

share.merge_schema = merge_schema = (arg1, arg2)->
  if _.isString(arg1)
    key= arg1
    obj= arg2
  else
    obj= arg1
  for collection_name,schema_def of obj
    collection = share.collection_for_name(collection_name)
    orig_schema = collection?.simpleSchema()?.schema()
    for field_name,field_def of schema_def
      if field_name== "section_ids.$"
        debugger
      if key?
        field_def = 
          _.zipObject [key],[field_def]
      for field_prop_name,field_prop  of field_def
        orig_schema[field_name]?={}
        if _.isObject orig_schema[field_name][field_prop_name]
          _.merge orig_schema[field_name][field_prop_name], field_prop
        else if not orig_schema[field_name][field_prop_name]?
          orig_schema[field_name][field_prop_name]=field_prop
    share.replace_schema orig_schema, collection_name
share.replace_schema= (new_schema, collection)->
  unless new_schema instanceof SimpleSchema
    new_schema= new SimpleSchema new_schema
  if _.isString collection
    collection= share.collection_for_name collection
  Schemas_key = _.findKey Schemas , (s)->s== join.config.schemas_for_collection(collection)?[0]?.schema
  if Schemas_key
    Schemas[Schemas_key] = new_schema
    collection.attachSchema Schemas[Schemas_key], {replace:true}
  else

share.on_json_loaded ->

  unless join.config.collection_for_name('submission_files')
    throw new Error "no submission_files collection found!"
  schema = Schemas.Submissions._schema
  SimpleSchema.extendOptions
    minWordCount:Match.Optional(Number)
    maxWordCount:Match.Optional(Number)
    input_spec:Match.Optional(Object)
  SimpleSchema.messages
    "not enough words": "Please enter more words"
    "too many words":"Please reduce the word count"
  wordcounter = (markdown)->
  
  
  text_word_counter= (text)-> 
    wl = text.split(/\W+/)
    len = wl.length   
    ## For perfomance reasons the filter function is avoided as only the first and last element could be empty strings
    if len >0 and wl[0]==""
      len--
    if len >1 and wl[len-1]==""
      len--
    return len


  SimpleSchema.addValidator -> 
    if (min=@definition.minWordCount) or max=@definition.maxWordCount
      #set max as it  is not evaluated if min is set
      max?=@definition.maxWordCount
      if @value?
        text = removeMd(@value)
      else
        return
      num =  text_word_counter  text
      return "not enough words"  if min? and num < min
      return   "too many words"  if max? and num > max
  glob= this
    
  
            

  merge_schema
    submissions:
      promoted_products_description:
        minWordCount: 1
        maxWordCount: 30
      context_description:
        maxWordCount: 300
      campaign_summary:
        maxWordCount: 400
        minWordCount: 1
      target_audience:
        maxWordCount: 150
        minWordCount: 1
      results_summary:
        maxWordCount: 300
      confidential_info:
        maxWordCount: 300
      credit_contacts:
        minCount:1
        maxCount:10
      sections:
        minCount:1
        maxCount:5
  
  

  share.job_titles= job_titles= [
    "Sr. Art Director",
    "Art Director",
    "Jr. Art Director",
    "Sr. Copywriter",
    "Copywriter",
    "Jr. Copywriter",
    "Video Creative Director",
    "Head of Strategy",
    "Sr. Strategic Planner",
    "Strategic Planner",
    "Jr. Strategic Planner",
    "Client Service Manager  = Client Service Manager",
    "Group Account Director",
    "Sr. Account Manager",
    "Account Manager",
    "Jr. Account Manager",
    "Sr. Account Executive",
    "Account Executive",
    "Jr. Account Executive",
    "Sr. AV Producer",
    "AV Producer  = Producer",
    "Jr. AV Producer",
    "Head of Design",
    "Sr. Graphic Designer",
    "Graphic Designer",
    "Jr. Graphic Designer",
    "Head of Communication Design",
    "DTP",
    "Head of Digital",
    "Web Developer",
    "Backend Web Developer",
    "Frontend Web Developer",
    "Technical Director",
    "Social Media Manager  = Head of Social Media",
    "Social Media Executive = Social Media Specialist",
    "Community Manager",
    "Events Manager",
    "PR Specialist",
    "PR Manager ",
    "Creative Leader ",
    "Operations Manager",
    "Managing Director"
  
  ]
  merge_schema "input_spec",
    sections:
      name:
        label:true
    categories:
      name:
        label:true
    submissions:
      promoted_products_description:
        placeholder: "Enter here a short description of what you created"
      #submitter_id:
      #  placeholder: "Legal Entity"
      #section_ids:
      #  placeholder: "Select sections"
      
      #brand:
      #  placeholder: "The promoted Brand"
      #context_description:
      #  placeholder: "In what circumstantions did you become creative"
      campaign_summary:
        placeholder: "objectives, strategy, creative idea and implementation"
      target_audience:
        placeholder: "Core audience & more"
      results_summary:
        placeholder: "Outcome & impact"
      confidential_info:
        placeholder: "For juries eyes only!"
      "credit_contacts.$.role":
        placeholder:"The Job title or role played"
        autocomplete:
          type:'horsey'
          suggestions: job_titles
          allow_custom: true
      "production.contacts.$.role":
        placeholder:"The Job title or role played"
        autocomplete:
          type:'horsey'
          suggestions: job_titles
          allow_custom: true
      "media.contacts.$.role":
        placeholder:"The Job title or role played"
        autocomplete:
          type:'horsey'
          suggestions: job_titles
          allow_custom: true   
      "other_companies.$.role":
        placeholder: "Function of the company within the project"
        ###autocomplete:
          type:"horsey"
          suggestions: form_ui.company_roles
          allow_custom: true
        ###     
      "files.$.is_case_file":
        switch:
          onText: "Case File"
          offText: "Campaign File" 

    contacts:
      name:
        placeholder: "Name, Surname"
        label: true
      is_company:
        switch:
          onText: "Yes"
          offText: "No" 
      email:
        placeholder: "Email address"
      job_title:
        placeholder: "Formal or informal"
      phone:
        placeholder: "Phone Number +40 ..."
      legal_identifyer:
        placeholder: "CUI/VAT-ID/reg. No"

      company_type:
        placeholder: "The main field of engagement"
        autocomplete:
          type:"horsey"
          suggestions: form_ui.company_roles
          allow_custom: true

