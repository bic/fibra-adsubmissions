_= lodash
toggle_by_value= (value_cmp)->
  (value)->
    $(this.firstNode).siblings().filter('.form-control').parent('.form-group').toggle(value == value_cmp)
share.submitting_entity =
  schema_def:
    draft:
      type:Boolean
      optional:true
      autoform:
        type:"hidden"
    name:
      label: "Your Agency Name / Your Full Name"
      type:String
    email:
      type:String
      regEx:SimpleSchema.RegEx.Email
    is_company:
      type:Boolean
      label: "You are submitting as a"
      defaultValue:false
      autoform:
        type:"boolean-radios"
        trueLabel:'Company/Agency'
        falseLabel:'Person'
      control_field:"is_company"
    legal_entity:
      type:String
      optional:true
      label: "Legal Entity Name ( S.R.L / S.A)"
      autoform:
        type:"hidden"
      controlled_by:
        is_company: toggle_by_value(true)

    agency_type:
      label:'Type of Agency / Company'
      type: 'String'
      optional:true
      autoform:
        type:'selectize'
        options:form_ui.company_roles.map (x)=>{value:x}
        selectizeOptions:
          multiple:false
          
          labelField: "value"
          valueField: "value"
          searchField: "value"
          create:true
        #isReactiveOptions: true
      controlled_by:
        is_company: toggle_by_value(true)