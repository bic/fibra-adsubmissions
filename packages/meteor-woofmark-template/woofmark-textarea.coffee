


Template.woofmark_textarea.default_options= default_options = 
  type : "text"
  placeholder: "Start typing ..."
  editor_only_with_focus:true
  render:
    modes: (button, id) ->
      switch id 
        when 'markdown'
          button.textContent = 'text(markdown)'
        when 'wysiwyg'
          button.textContent = 'visual'
        else
          button.textContent = id
      button.className += ' woofmark-mode-' + id
      button.className += ' btn btn-sm btn-default'
      return button
    commands:(button,id) ->
      button.innerText = button.textContent = woofmark.strings.buttons[id]
      button.className += ' woofmark-mode-' + id
      button.className += ' btn btn-sm btn-default'
      return button
  text_word_counter: (text,memoized_words_list)-> 
    wl = memoized_words_list(text)
    len = wl.length   
    ## For perfomance reasons the filter function is avoided as only the first and last element could be empty strings
    if len >0 and wl[0]==""
      len--
    if len >1 and wl[len-1]==""
      len--
    return len
    
  text_char_counter: (text, memoized_words_list)-> 
    ret = 0
    wl = memoized_words_list(text)
    for x in wl
        #this skips possib
        ret += x.length
    if wl.length >1
      ret += wl.length-1
    ## counts word splits as 1 char
    
    len= wl.length
    if len >0 and wl[0]==""
      ret--
    if len >1 and wl[len-1]==""
      ret--
    return Math.max ret,0

      ## here we remove the one char adden in excess in the prev. loop
    
if Package['pba:megamark']?
  default_options.parseMarkdown= Package['pba:megamark'].megamark
if Package['pba:domador']?
  default_options.parseHTML= Package['pba:domador'].domador
if Package['pba:remove-markdown']
  default_options.md2txt= Package['pba:remove-markdown'].removeMd
  default_options.display_word_count = true
  default_options.count_input = 'text'
woofmark_options = [
    "fencing",
    "markdown",
    "html",
    "wysiwyg",
    "defaultMode",
    "storage",
    "render",
    "images",
    "attachments",
    "xhr",
    "parseMarkdown",
    "parseHTML"
  ]
template_options = [
    "editor_only_with_focus",
    "word_count",
    "md2txt",
    "text_word_counter",
    "text_char_counter",
    "value",
    "sync_text_area",
    "display_word_count",
    "count_input"

  ]
pick_woofmark_options= (config_object)->
  ret = _.defaults {},  config_object, default_options 
  ret = _.pick ret, woofmark_options
  if config_object.render
    ret.render = _.defaults ret.render, default_options.render
  else if not _.isNull config_object.render
    ret.render = default_options.render
  return ret

pick_template_options= (config_object)->
  ret=_.defaults {} , config_object, default_options  
  _.pick ret, template_options
do(tmpl= Template.woofmark_textarea) ->
  tmpl.helpers
    attributes:->
      _.pick _.defaults({},Template.currentData() , default_options ), 'text,placeholder,id,class'.split(',')
      
    value:->
      inst= Template.instance()
      if inst.value?
        return inst.value.get()
      else if inst.options.value?
        return inst.options.value
      else
        return
    label_string:->
      return Template.instance().labeldef?.content
    label_attributes:->
      return _.omit(Template.instance().labeldef, 'content')
    word_count_var: ->
      return  Template.instance().wordcounter
    display_word_count: -> 
      # only display if both wordcounting and it's display_word_count are truish
      @display_word_count and Template.instance().wordcounter?
  
  create_editor = (data)->
    options= pick_woofmark_options data
    editor = woofmark(@find('textarea'), options)

    $(editor.textarea).data().editor= editor
    $(editor.textarea).addClass('form-control')
      .parent('.wk-container')
      .find('.wk-switchboard,.wk-commands')
      .addClass('btn-group')
    $('.wk-wysiwyg').addClass()

    if _.isFunction(data.on_editor_create)
      data.on_editor_create(editor)

    return editor
  word_count_func = (tmpl)->
      if tmpl.wordcounter?
        text = tmpl.editor.value()
        if  tmpl.options.count_input == 'text'
          text = tmpl.options.md2txt text

        tmpl.wordcounter.set
          word_count : tmpl.options.text_word_counter text
          char_count : tmpl.options.text_char_counter text
      ## The template instance is used for timing measurement id
        return text
  tmpl.onCreated ->
    

    @options=  pick_template_options this.data
    if @data.label
      @labeldef ={}
      if _.isString(@data.label)
        @labeldef.content=@data.label
      else
        @labeldef = @data.label
      unless @labeldef.for ==null
        if @data.id
          @labeldef.for=@data.id
    if @options.word_count
      unless @options.md2txt?
        throw new Error('you need to set md2txt function or to include pba:remove-markdown')
      if _.isFunction(@data.word_count.set)
        @wordcounter= @data.word_count
      else
        @wordcounter = new ReactiveVar()
    

      ###
      This is a performance tweak 
      - to avoid splitting the input more than once
      - to avoid while doing so too big a runtime cache, keeping all input values in memory forever
      ###
      memoized_words_list=  _.memoize (text)->text.split(/\W+/)
      if @options.text_char_counter == default_options.text_char_counter
        @options.text_char_counter = (text)->
            default_options.text_char_counter text, memoized_words_list
      if @options.text_word_counter == default_options.text_word_counter
        @options.text_word_counter = (text)->
            default_options.text_word_counter text, memoized_words_list



    if @options.value?

      if _.isFunction @options.value.get
        ## ok we will use the existing or create a ReactiveVar
        if _.isFunction @options.value.set
          @value=options.value
        else
          @value= new ReactiveVar (@options.value.get())
      


  tmpl.onRendered ->
    @editor=create_editor.call this , this.data
    if @options.editor_only_with_focus
      $(@findAll('.wk-switchboard,.wk-commands')).hide()
    else
      # this supresses events for adding/removing woofmark on focus
      this.focus_guard= true 
    if @wordcounter?
      #initial wordcount setting
      word_count_func this
    debugger
    if @options.sync_text_area
      #TODO: This misses all other events
      $(@find('.woofmark-container')).on 'keyup', (e)=> 
        $(@find('textarea')).text(@editor.value())
    if @value
      $(@find('.woofmark-container')).on 'keyup', (e)=>
        @value.set(@editor.value())


  tmpl.events
    'focusin textarea, focusin .wk-wysiwyg': (e,tmpl)->
      #unless tmpl.focus_guard 
      console.log( "focusin:" , e.target )
      $(tmpl.findAll('.wk-switchboard,.wk-commands')).show()
    'focusout textarea, focusout .wk-wysiwyg':(e,tmpl)->
      unless tmpl.focus_guard
        console.log( "focusout:" , e.target )
        $(tmpl.findAll('.wk-switchboard,.wk-commands')).hide()
        
    'mousedown' :(e,tmpl) ->
      console.log('mousedown')
      tmpl.focus_guard= true
    'mouseup' :(e,tmpl)->
      console.log('mouseup')
      tmpl.focus_guard= false
    'keyup textarea, keyup .wk-wysiwyg': _.debounce ((e,tmpl)-> word_count_func tmpl ), 500
  

do(tmpl=Template.word_count_display)->
  tmpl.helpers
    do_word_count:->@get()?
    do_char_count:->@get()?
    char_count: -> @get().char_count 
    word_count: -> @get().word_count



