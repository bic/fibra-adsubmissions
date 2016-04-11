
## config
defaults=
  # shows if the field is optional the optional_string
  show_optional:true
  optional_string: "opt"

  # shows if the field is requird the required_string
  show_required: false
  required_string: "req"
do(tmpl=Template.bs_label)->
  helpers=
    attrs: ->
      ret= _.pick  this , 'for,class'.split ","

      ret.for?= @field
      return ret
    show_optional:(inst)->
      if @force_optional?
        return @force_optional
      else if @show_optional?  
        return false unless @show_optional
        schema = share.schema_for_template_inst(inst)
        return @show_optional unless schema? 
        return schema.optional and defaults.optional_string
      else if defaults.show_optional
        schema = share.schema_for_template_inst(inst)
        return false unless schema? 
        return @show_required unless schema?
        return schema.optional and defaults.optional_string
    show_required:(inst)->
      if @force_required?
        return @force_required
      else if @show_required? 
        return @show_required unless @show_required
        schema = share.schema_for_template_inst(inst)
        return @show_required unless schema?
        return (not schema.optional) and defaults.required_string
      else if defaults.show_required
        schema = share.schema_for_template_inst(inst)
        return defaults.show_required unless schema?
        return (not schema.optional) and defaults.required_string
  tmpl.instance_helpers helpers

  ReactiveForms.createElement
    template: 'bs_label'