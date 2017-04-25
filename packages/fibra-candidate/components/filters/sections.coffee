_= lodash
do(tmpl=Template.category_selector)->
  helpers=
    categories: ->
      cur = Categories.find {}
      return _.sortBy cur.fetch(), (doc)-> parseInt(doc.number)
    tags:->
      cur= Tags.find
        category_id:@_id
      grouped= _.groupBy cur.fetch() , 'abbrev'
      ret= []
      for key, val of grouped
        ret.push
          abbrev:key
          count:val.length
      return ret
    entries:->
      cur= Sections.find
        category_id: @_id
      
      section_names = cur.map (doc)->doc.name
      sub_cur= Submissions.find 
        'sections.name': 
          $in: section_names
      ret = sub_cur.count()
      if ret
        return ret
      else
        return
    name:->
      "#{@number}. #{@name}"
    glyphicon:(inst)->
      dict = inst.get('filter')
      names= dict.get('sections')

      sections_in_cat= Sections.find({category_id:this._id}).map (doc)->doc.name
      unless names?
        return 'glyphicon-unchecked'
      else if (dif =_.difference(sections_in_cat ,names)).length ==0
        return 'glyphicon-check'
      else
        return 'glyphicon-unchecked'
  tmpl.instance_helpers helpers
  tmpl.events
    'click .do-toggle-category-filter':(e,inst)->
      dict = inst.get('filter')
      names= dict.get('sections')

      sections_in_cat= Sections.find({category_id:this._id}).map (doc)->doc.name
      unless names?
        dict.set 'sections', sections_in_cat
      else if (dif =_.difference(sections_in_cat ,names)).length
        names.push dif ...
      else
        names= _.difference(name,sections_in_cat)
      dict.set('sections', names)

do(tmpl=Template.section_selector)->
  helpers=
    sections: ->
      Sections.find {category_id:@category_id},
        sort:
          name:1
    tags:->
      cur=Tags.find
        section_id:@_id
      grouped= _.groupBy cur.fetch() , 'abbrev'
      ret= []
      for key, val of grouped
        ret.push
          abbrev:key
          count:val.length
      return ret
    short_name: -> 
      parts = @name.split(' ')
      return parts[0] + ' ' +  @short_name
    glyphicon:(inst)->
      filter= inst.get('filter')
      sec_filter= filter.get('sections')
      unless sec_filter
        return 'glyphicon-unchecked'
      else
        if -1< sec_filter.indexOf @name
          return 'glyphicon-check'
        else
          return 'glyphicon-unchecked'
    section_sort_btn_class:(inst)->
      if @name == Session.get('section_sort')
        return 'btn-primary'
      else
        return 'btn-default'
  tmpl.instance_helpers helpers
  tmpl.events
    'click .do-toggle-section-filter':(e,inst)->
      dict= inst.get('filter')
      filter= dict.get('sections')
      filter?=[]
      if -1< filter.indexOf @name
        filter= filter.filter (name)=> name!= @name
      else
        filter.push @name
        filter = [filter...]
      dict.set 'sections', filter
    'click .do-toggle-section-sort':(e,inst)->
      prev= Session.get('section_sort')
      if prev == @name
        Session.set('section_sort', undefined)
      else
        Session.set('section_sort', @name)

  form_ui.filter_compiler.add 'submissions', (dict)->
    filter= dict.get('sections')
    if filter?
      @$and
        'sections.name':
          $in: filter



