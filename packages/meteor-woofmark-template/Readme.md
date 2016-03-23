# Woofmark Meteor template

## What is
This Package provides a wrapper around the woofmark editor with some additional functionality.


The additional functionality:

- Word and character counting to a reactive sink (a Reactive Var to write to) 
- Adds a `label` element if the label configuration option or a label rendering template is provided
- Adds bootstrap classes:
  - `form-control` class to the textarea
  - `btn-group` class to the `wk-commands` and `wk-switchboard` button containers
  - `btn btn-sm btn-default` to the buttons in these containers
- Hide/Unhide on focus functionality for the Toolbar

The bootstrap classes transform the toolbar (if bootstrap is loaded) into a [bootstrap toobar](http://getbootstrap.com/components/#btn-groups)


## [Woofmark](https://github.com/bevacqua/woofmark) Configuration
The template can be called with these [`woofmark`](https://github.com/bevacqua/woofmark) specific arguments

- `woofmark` options (docs in [beaquas woofmark reop](https://github.com/bevacqua/woofmark) )
  - `fencing`, `markdown`, `html`, `wysiwyg`, `defaultMode`, `storage`, `render`, `images`, `attachments`, `xhr`
  - `parseMarkdown`:  with a weak dependency on [`pba:megamark`](https://github.com/paulbalomiri/meteor-megamark), a Meteor wrapper for [`megamark`](https://github.com/bevacqua/megamark) 
  - `parseHTML`: with a weak dependency on [`pba:domador`](https://github.com/paulbalomiri/meteor-domador), a Meteor wrapper for [`domador`](https://github.com/bevacqua/domador)
The weak dependencies mean that you are free to provide whatever parsers you wish, but that _defaults_ are set to [`pba:megamark`] and [`pba:domador`] if those are present.
## Template specific configuration

### DOM config ###
- `placeholder` , `type`, `id` : attributes to be set on the `textarea` element
-  `label`: if this option is present a label will be generated
  - if the option contains a **String** then the `for` attribute will be set to the id of the `textarea` and the content to the string value
  - if the option contains a `Template` Object, than this template will be rendered in the context of `woofmark-template`
  - if the option contains an **Object**, than the `for` and `content` properties will be read to generate a label
###value & sync_text_area###
  The `textarea`'s text can be set by supplying a `value` property to the template, which may be
  - a string to initialize the box with
  - a ReactiveVar to set the textbox value initially, and to update when the input changes

  `sync_text_area` keeps the value of the textarea in sync with the html output.
  `sync_text_area` is not tested for the `html` mode of `woofmark` and will probably not work. (TODO: find a workaround or just document the absence thereof) 

  Note that keeping in sync means listenting to `keyup` events in real time (possible performance issue)

### editor_only_with_focus ###
  if `true`(default) than the toolbar will only be shown when the input is focused
  JQuery is used to `hide()` and `show()` the toolbar



### wordcount ###
  can be set to `true` or an object with a `set(value)` function property (intended for usage with `ReactiveVar`).
  This actives the counter when the input has focus.
  The value set has the `word_count` and `char_count` properties
  defaults to true if [`pba:remove-markdown`](https://github.com/paulbalomiri/meteor-remove-markdown) is present.

  Note that if you use a reactive var, you could do whatever you want with the result(like validating the form e.t.c)
  The wordcounting is debounced (as in `_.debounce`) by 500 ms

  The default counting
  - does not count the whitespace preceeding/trailing the text
  - assumes repeated whitespace to count as one char
  - whitespace is whatever /\W+/ is
  - counts text (= stripped markdown)

  __Wordcount fine tuning __
  - `display_word_count=true` to display word and character count - defaults to `true` if `pba:remove-markdown` package is present (weak dependency)
  - `md2txt = function(text){return convert(text)}` A function to convert markdown to text with the signature`md2txt(md_string)`. This is needed for `wordcount`
  md2txt uses [`remove-markdown` npm package](https://github.com/stiang/remove-markdown) if its Meteor wrapper [`pba:remove-markdown`](https://github.com/paulbalomiri/meteor-remove-markdown) is present (weak dependency). Look at the npm package if you want to supply different arguments (such as not stripping list headers)
  - `count_input="text"` default is "text" if `md2txt` is present. `"markdown"` will skip the md->txt transformation before counting.
  

### text_word_counter  and text_char_counter ###
  defines the method of counting words and characters
  The default is _equivalent to_: 
  ```
  text_word_counter= (text)-> text.split(/\W+/).filter("").length
  text_char_counter= (text)-> text.replace(/\W+/, ' ').length
  ```
  The actual counters avoid splitting the text twice per operation by using the _.memoize function on a per Template instance level

##`woofmark-textarea` use##

To use the template just provide any of the parameters in its context, either by arguments or using a   `with` block and a helper

**Simple Example**
Just use this in your template code (sorry it's jade)
```
woofmark_options id="promoted_products" placeholder = "You really can type here" 
```
**Helper Example**
Here is an example which merges a custom default with properties which you might want wo keep in the html/jade template

define a helper such as:
```
woofmark_options: (kwargs)->
  ret=
    html:false
    defaultMode: 'html'
    wysiwyg_content_class: 'form-control'
    wordcount:true 

  return  _.defaults  kwargs.hash , ret
```
```
with woofmark_options id="promoted_products" placeholder = "Type, type, type...." label="Promoted Product(s) / Service(s) Description"
  +woofmark_textarea
```


## TODO##
(only if time/interest permits)

- partial templates with `contentFor` for label and possibly `textarea`/`input`
- move word count and focus functionalities to separate packages
- sync markdown in `textarea` with editor contents
- change doc to use `html`/`js` template example instead of `jade`/`coffee`
- use [`sdecima:javascript-detect-element-resize`](https://github.com/sdecima/javascript-detect-element-resize) to keep the input size in sync on editor mode switch
- PRs for [`megamark`](https://github.com/bevacqua/megamark) to avoid monkeypatching DOM
- make the textcounter even more performant by timing each debounce according to the previous wordcount duration



## Other Packages ##
This package was - from it's inception - meant to be used together with 
- [`pba:megamark`](https://github.com/paulbalomiri/meteor-megamark)
- [`pba:domador`](https://github.com/paulbalomiri/meteor-domador)
- [`pba:remove-markdown`](https://github.com/paulbalomiri/meteor-domador)
# Credits #
This package stands on giant shoulders :)

## [Nicolás Bevacqua](https://github.com/bevacqua) made this possible ##

- [`woofmark`](https://github.com/bevacqua/woofmark)
- [`domador`](https://github.com/bevacqua/domador)
- [`megamark`](https://github.com/bevacqua/megamark) 

## [Stian Grytøyr](https://github.com/stiang) made counting markdown words easy##
- [`remove-markdown`](https://github.com/stiang/remove-markdown)
