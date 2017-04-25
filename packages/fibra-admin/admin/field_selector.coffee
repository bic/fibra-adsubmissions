do(tmpl=Template.field_selector)->
  tmpl.onCreated ->
    @field_def = new ReactiveVar
      All:
        Submission:
          Title: 'title'
          Brand:'brand'
          Client: 'client'
          Sections:'sections.name'
        Names:
          'Submitter Contact': 'submitter_contact.name'
          'Credit Contact': 'credit_contacts.name'
          'Client Contact': 'client.designated_contact.name'
          'Production Company':
            "Contact":  'production_company.designated_contact.name'
            "Team Member":'production_company.contacts.name'
          'Media Agency': 
            'Contact': 'media_company.designated_contact.name'
            'Team Member': 'media_company.contacts.name'
          'Other Agency':
            'Contact': 'other_company.designated_contact.name'
            'Team Member': 'other_company.contacts.name'
        
        Files:
          Name:"name"
          Translation:"translation"
        Descriptions:
          Context:"context_description"
          "Campaign Summary": "campaign_summary"
          "Target Audience": "target_audience"
          "Media Appearance": "media_appearance"
          "Results":"results_summary"
          "Confidential": "confidential_info"


  helpers= 
    dropdown_content_ctx: (inst)->
      if _.isString fields
        fields= fields.split ','
      field_def: inst.field_def
      fields: @fields
      force_expand_levels:1
  tmpl.instance_helpers helpers
do(tmpl=Template.field_selector_dropdown_content)->
  
  tmpl.onCreated ->
    @force_expand = new ReactiveDict()
  included = (field_def, fields)->
    all = true
    none= true
    if _.isObject field_def
      for key,val of field_def
        incl= included val,fields
        unless incl
          all= false
          unless incl?
            none= false
        else
          none= false
    else if _.isString field_def
      return -1< fields.indexOf(field_def)
    if all
      return true
    else if none
      return false
    else 
      return
  extract_fields=(field_def)->
    ret = []
    if _.isObject field_def
      for key, val of field_def
        ret.push extract_fields(val)...
      return ret
    else
      return [field_def]
    
  helpers=
    fields:(inst)->
      ret = []
      field_def = @field_def
      if field_def instanceof ReactiveVar
        field_def= field_def.get()
      for key, val of field_def
        ret.push
          name:key
          value:val
          fields:@fields
          force_expand_levels: @force_expand_levels or 0
      return ret  
    has_children: (inst)->
      return _.isObject @value
    glyphicon_classes:(inst)->
      is_included = included @value,@fields.get()
      if is_included?
        if is_included
          return 'glyphicon-check'
        else
          return 'glyphicon-unchecked'
      else
        return 'glyphicon-option-horizontal'
    expand_children:(inst)->
      if @force_expand_levels? and @force_expand_levels >0
        return true
      if force= inst.force_expand.get(@name)
        return true
      else if force?
        return false
      else
        is_included = included @value,@fields.get()
        if is_included?
          #true and false means we
          return false
        else
          return true
    show_btn:(inst)->

      @force_expand_levels == 0
    subfields:(inst)->
      field_def:@value
      fields:@fields
      force_expand_levels: Math.max(@force_expand_levels-1,0) or 0

  
  tmpl.instance_helpers helpers
  tmpl.events
    "click .do-expand-children":(e,inst)->
      e.preventDefault()
      e.stopPropagation()
      data= Blaze.getData e.currentTarget
      current= $(e.currentTarget).hasClass 'active'
      inst.force_expand.set data.name,not current
    "click .do-select":(e,inst)->
      e.preventDefault()
      e.stopPropagation()
      data= Blaze.getData e.currentTarget
      possible_fields= extract_fields(data.value)
      current = data.fields.get()
      dif= _.difference( possible_fields, current)
      if dif.length==0
        #all were set, so unset now
        current= _.difference current, possible_fields
      else
        #none or some were set, set them all (=add difference)
        current.push dif...
      @fields.set(current)
  
