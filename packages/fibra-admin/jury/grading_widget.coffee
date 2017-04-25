_= lodash
share.criteria= criteria= ['originality', 'context','execution']
do(tmpl=Template.grading_widget)->
  tmpl.onCreated ->
    @state_dict= @data.state
    @value_dict= @data.value_dict or new ReactiveDict()
  helpers=
    sections:(inst)->
      sub= Submissions.findOne inst.data.data._id
      sub.sections
    has_more_than_one_section:(inst)->
      sub= Submissions.findOne inst.data.data._id
      if sub.sections?.length >1
        return true
      else
        return false
    show_section_grades:(inst)->
      if helpers.has_more_than_one_section.call this,inst
        return helpers.expand_rows.call this,inst
      else
        true
    
    expand_rows: (inst)->
      key = [inst.data.data._id, 'expand_rows'].join '.'
      inst.state_dict.get key
    expand_columns: (inst)->
      key = [inst.data.data._id, 'expand_columns'].join '.'
      inst.state_dict.get key
    
    row_expand_class:(inst)->
      prefix = 'glyphicon-chevron-'
      if helpers.expand_rows.call this,inst
        return prefix+'up'
      else
        return prefix + 'down'
    column_expand_class:(inst)->
      prefix = 'glyphicon-chevron-'
      if helpers.expand_columns.call this,inst
        return prefix + 'left'
      else
        return prefix + 'right'
    evaluation:(inst)->
      #evaluations for this section
      key = 
        submission:inst.data.data._id
        owner_account:Meteor.userId(), 
        section: @name 
      return Evaluations.findOne(key)
    evaluations:(inst)->
      #evaluations for all sections
      key = 
        submission:inst.data.data._id
        owner_account:Meteor.userId()
      Evaluations.find(key)
    evaluation_input:(inst)->
    submission_id:(inst)->
      ret= Template.currentData(inst.view).data._id
      unless ret
        debugger
      return ret
    show_tags:(inst)-> 
     true
    show_others:(inst)->
      ret = Session.get 'show_hide_others'
      unless ret? 
        return true
      else
        return ret
  tmpl.instance_helpers helpers
  
  calculate_mean= (criteria...)->
    l= crit.length
    sum=0
    count=0
    for criterium in criteria
      if criterium?
        count++
        sum+=criterium
    return sum/count
  
  tmpl.events 
    'click .do-toggle-expand-columns':(e,inst)->
      key = [inst.data.data._id, 'expand_columns'].join '.'
      inst.state_dict.set key , not inst.state_dict.get key
    'click .do-toggle-expand-rows':(e,inst)->
      key = [inst.data.data._id, 'expand_rows'].join '.'
      inst.state_dict.set key , not inst.state_dict.get key

do ->
  get_key = (data)->
    submission:data.submission 
    createdBy: Meteor.userId()
    section:data.section
  get_values=(data)->
    key = get_key data
    unless key?
      return
    Evaluations.findOne key 
  get_mean=(data)->
    val= get_values(data)
    unless val?
      return
    sum= 0;
    n=0;
    for key in criteria
      if _.isFinite (num= Number.parseFloat(val[key]))
        n++
        sum+=num
    if n==0
      return
    else
      return sum/n
  get_value=(data)->
    key= get_key(data)
    fields={}
    fields[data.name]=1
    return Evaluations.findOne key, 
      fields: fields 
  evaluation_key_fields = ['_id', 'submission', 'section'] 
  do(tmpl=Template.evaluation_grade_td)->
    
    helpers=
      grade: (inst)->
        inst.suppress_value_change= true
        val= get_value this
        Tracker.afterFlush ->
          inst.suppress_value_change= false
        return val?[@name] or ''

      placeholder: (inst)->
        get_mean(this)
    tmpl.instance_helpers helpers 
    tmpl.events
      ## click input.form-control, 
      'propertychange input.form-control, change input.form-control, keyup input.form-control, input input.form-control, paste input.form-control':(e,inst)->
        if inst.suppress_value_change
          console.log('suppressed event:' , e)
          return
        elem = $(e.currentTarget)
        data= Template.currentData()
        old_value = get_value(data)
        mod={}
        mod[data.name]=elem.val()
        if old_value?
          old_input_value= old_value[data.name]
          unless old_input_value==elem.val()
            if mod[data.name].length
              mod.draft= true
              mod =
                $set:mod
            else
              mod[data.name]= true
              mod=
                $set:
                  draft:true
                $unset: mod
            Evaluations.update old_value._id, mod
        else
          unless mod[data.name].length==0
            console.log("inserting from evaluation_grade_td")
            Evaluations.insert _.extend  mod , _.pick(data,evaluation_key_fields) ,{draft:true}

        console.log "oldval #{JSON.stringify old_value}, new: #{elem.val()}, mod: #{JSON.stringify mod}" 
  do(tmpl=Template.overall_categories_grade_td)->
    helpers=
      mean:->
        get_mean this
      same_values:->
        val= get_values this
        crits= _.values _.pick val, criteria
        val = null
        for crit in crits
          if crit?
            unless val?
              val= crit
            else
              unless crit==val
                return false
        return true


    set_all=(data , value_picker)->
      value = get_values(data)
      if value?
        values = _.values(_.pick(value, criteria)).filter (val)-> _.isFinite Number.parseFloat(val)
        val = value_picker values
        mod = _.fromPairs criteria.map (name)->[name, val]
        mod.draft= true
        Evaluations.update value._id,
          $set: mod
    tmpl.instance_helpers helpers
    tmpl.events
      
      'click .do-set-min':(e,inst)->
          set_all Template.currentData(), (vals)->
            return Math.min.apply null, vals
      'click .do-set-max':(e,inst)->
          set_all Template.currentData(), (vals)->
            return Math.max.apply null, vals
      'click .do-set-avg':(e,inst)->
          set_all Template.currentData(), (vals)->
            unless vals.length
              return
            sum=0
            n=0
            for val in vals
              sum = sum + Number.parseFloat val
              n++
            return sum/n    
      'click .do-unset':(e,inst)->
        data = Template.currentData()
        values = get_value(data)
        mod =
          $set:
            draft:true
          $unset: _.fromPairs criteria.map (name)->
            [name,true]
        Evaluations.update values._id,
          mod
        return
      'propertychange input.form-control, change input.form-control, keyup input.form-control, input input.form-control, paste input.form-control':(e,inst)->
       if inst.suppress_value_change
          console.log('suppressed event:' , e)
          return
        elem = $(e.currentTarget)
        data= Template.currentData()
        old_value = get_values(data)
        
        val= elem.val()
        mod = _.fromPairs criteria.map (name)->
          [name, val]
        if old_value?

          old_input_value= String _.values(_.pick(old_value, criteria)).reduce (prev, val, l)->
              unless prev
                return val/l.length
              else
                return prev+ val/l.length
            ,
              undefined
          unless old_input_value== val
            if val? and val.length 
              mod.draft= true
              mod =
                $set:mod
            else
              for name in criteria
                mod[name]= true
              mod=
                $set:
                  draft:true
                $unset: mod
            Evaluations.update old_value._id, mod
        else
          if val? and val.length
            console.log 'inserting from overall_categories_grade_td'
            Evaluations.insert _.extend  mod , _.pick(data,evaluation_key_fields) ,{draft:true}
        console.log "oldval #{JSON.stringify old_value}, new: #{elem.val()}, mod: #{JSON.stringify mod}" 
  do(tmpl= Template.overall_criteria_grade_td)->
    helpers=
      same_values:(inst)->
        vals= Evaluations.find({createdBy:Meteor.userId(), submission:this.submission}).fetch()  
        prev= null
        for val in vals
          if val[@name]?
            unless prev?
              prev = val[@name]  
            else
              unless prev == val[@name]
                return false
        return true
      mean:(inst)->
        vals= Evaluations.find({createdBy:Meteor.userId(), submission:this.submission}).fetch()  
        sum= 0
        n=0
        for val in vals
          if val[@name]?
            n++
            sum+=Number.parseFloat(val[@name])
        if n==0
          return
        return sum/n
    tmpl.instance_helpers helpers
    tmpl.events
      'propertychange input.form-control, change input.form-control, keyup input.form-control, input input.form-control, paste input.form-control':(e,inst)->
      
        sub = Submissions.findOne(@submission)
        key=
          createdBy:Meteor.userId()
          submission:@submission
        val= $(e.currentTarget).val()

        for {name:section} in _.uniqBy sub.sections, 'name'
          key.section= section 
          evals = Evaluations.findOne key
          if val? and val.length
            mod =
              draft:true
            mod[@name]=val
            unless evals?
              console.log("inserting from overall_criteria_grade_td")
              Evaluations.insert _.extend mod, key
            else
              Evaluations.update evals._id,
                $set: mod
          else
            if evals?
              Evaluations.update evals._id,
                $set:
                  draft:true
                $unset: _.fromPairs [[@name,1]]
do(tmpl= Template.overall_total_td)->
  helpers=
    same_values:(inst)->
      vals= Evaluations.find({createdBy:Meteor.userId(), submission:this.submission}).fetch()  
      prev= null
      for val in vals
        for name in criteria
          if val[name]?
            unless prev?
              prev = val[name]  
            else
              unless prev == val[name]
                return false
      return true
      
    mean:(inst)->
      
      vals= Evaluations.find({createdBy:Meteor.userId(), submission:this.submission}).fetch()  
      sub = Submissions.findOne(@submission)
      by_section = _.fromPairs sub.sections.map (sec)->
        [sec.name , {sum:0,n:0}]
      unless vals.length
        return
      for val in vals
        s= by_section[val.section]
        for name in criteria
          if val[name]?
            s.n++
            s.sum+=Number.parseFloat(val[name])
      
      sum=0
      n=0
      for name, mean_params of by_section
        if mean_params.n>0
          sum+= mean_params.sum / mean_params.n
          n++
      if n==0
        return
      return sum/n
    
  tmpl.instance_helpers helpers

  insert_blocker= {}
  tmpl.events
    'propertychange input.form-control, change input.form-control, keyup input.form-control, input input.form-control, paste input.form-control':(e,inst)->
      
      val= $(e.currentTarget).val()
      sub = Submissions.findOne(@submission)
      return if insert_blocker[sub._id]
      key=
        createdBy: Meteor.userId()
        submission:@submission
      
      unless sub?
        throw Error "no submission _id:#{@submission}found"
      for {name:section} in _.uniqBy sub.sections, 'name'
        key.section= section
        vals = Evaluations.findOne key
        mod = _.fromPairs criteria.map (name)->[name,val]
        
        if val? and val.length
          unless vals? 
            insert_blocker[sub._id] = true
            console.log("inserting from overall_total_td")
            Evaluations.insert _.extend({draft:true},mod, key) , ->
              delete insert_blocker[sub._id]
          else
            Evaluations.update vals._id,
              $set: _.extend {draft:true}, mod
        else
          if vals?
            
            Evaluations.update vals._id,
              $set:
                draft:true
              $unset: _.fromPairs criteria.map (name)->[name,true]

      return


    'click .do-unset':(e,inst)->
      val_cur = Evaluations.find
          createdBy: Meteor.userId()
          submission:@submission
      mod = 
        $set:
          draft:true
        $unset: _.fromPairs criteria.map (name)->[name,1]
      for {_id:id} in val_cur.fetch()
        Evaluations.update id, mod
      return
round= (val)->
  short = Math.round(val*100)/100
  _.isFinite(short) and short or  val

split_other_labels= (l)->
  debugger
  ret = []
  for elm, idx in l
    if elm.grade?
      elm.grade = round elm.grade
    else
      debugger
    if idx == 0
      ret.push 
        fields:[elm]
    else if(idx %2)
      ret.push {is_br:true}, 
        fields:[elm]
    else
      ret[ret.length-1].fields.push elm
  ret

do(tmpl=Template.other_grades_overall_total)->
  juror_avg = (cur, initial)->
    sum=0
    count=0
    cur.forEach (stat)->
      if stat.by_juror?[initial]?.overall?.avg
        sum+= stat.by_juror[initial].overall.avg
        count++
    if count
      return sum/count
    else
      return
  tmpl.onRendered ->
    $(@findAll('[data-toggle="tooltip"]')).tooltip()
  helpers =
    avg:-> 
      sum=0
      count=0
      Stats.find({submission:this.submission}).forEach (stat)->
        if stat.overall?.avg?
          sum+=stat.overall.avg
          count++
      if count
        return round sum/count
      else
        return "-"
    rows:->
      cur = Stats.find({submission:this.submission})
      
      ret= []
      for juror in  share.jurors
        if juror.id == Meteor.userId
          continue
        avg = juror_avg cur, juror.initial
        ret.push
          tooltip: "#{juror.initial} - #{juror.name} " + (avg and " graded #{avg}" or "did not grade")
          grade: avg or "-"
          initial: juror.initial
      return split_other_labels ret
  tmpl.instance_helpers helpers
do(tmpl= Template.other_grades_section_overall)->
  tmpl.onRendered ->
    $(@findAll('[data-toggle="tooltip"]')).tooltip()
  helpers=
    avg: ->
      ret= Stats.findOne({submission:this.submission, section:this.section})
      return ret?.overall?.avg? and round(ret.overall.avg) or "-"
    rows:->
      ret=[]
      stat= Stats.findOne({submission:this.submission, section:this.section})
      for juror in  share.jurors
        if juror.id == Meteor.userId
          continue
        avg=stat.by_juror?[juror.initial]?.overall?.avg
        ret.push
          tooltip: "#{juror.initial} - #{juror.name} " + (avg and " graded #{avg}" or "did not grade")
          grade: avg? and avg or "-"
          initial: juror.initial
      return split_other_labels ret
  tmpl.instance_helpers helpers  
do(tmpl= Template.other_grades)->
  tmpl.onRendered ->
    $(@findAll('[data-toggle="tooltip"]')).tooltip()
  helpers=
    avg: ->
      debugger
      ret= Stats.findOne({submission:this.submission, section:this.section})
      return ret?[@name]?.avg? and round(ret[@name].avg) or "-"
    rows:->
      ret=[]
      stat= Stats.findOne({submission:this.submission, section:this.section})
      for juror in  share.jurors
        if juror.id == Meteor.userId
          continue
        avg= stat.by_juror?[juror.initial]?[@name]
        ret.push
          tooltip: "#{juror.initial} - #{juror.name} " + (avg and " graded #{avg}" or "did not grade")
          grade: avg? and avg or "-"
          initial: juror.initial
      return split_other_labels ret
  tmpl.instance_helpers helpers  
do(tmpl= Template.tag_editor)->
  share.tags= tags =
    shortlist:
      title:"Shortlist"
      abbrev: "SL"
    gold:
      title: 'Gold'
      abbrev: 'g'
    silver:
      title: 'Silver'
      abbrev: 's'
    bronze:
      title: 'Bronze'
      abbrev: 'b'
    grand_fibra:
      title: 'Grand FIBRA'
      abbrev: 'GF'
  evt_map= 
    'click .do-remove':(e,tmpl)->
      Tags.remove @_id
  helpers =
    tags: (inst)->
      submission = Template.parentData(3).data
      ret = Tags.find
        submission: submission._id
        section: @section
      debugger
      return ret
  for name , def of tags
    do(name=name, def=def)->  
        evt_map["click .do-add-#{name}"]=(e,inst)->
          debugger
          submission = Template.parentData(3).data
          doc = 
            draft:true
            submission: submission._id
            section:@section
            name:name
          section = Sections.findOne
              name: @section
          if section?
            doc.section_id= section._id
            doc.category_id= section.category_id
          Tags.insert _.extend doc, def
        helpers["show_#{name}"]= (inst)->
          submission = Template.parentData(3).data
          cur = Tags.find
            name: name
            submission: submission._id
            section: @section
          return cur.count()==0
      
  tmpl.events evt_map
  tmpl.instance_helpers helpers






