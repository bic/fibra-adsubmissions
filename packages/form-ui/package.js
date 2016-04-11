Package.describe({
  name: 'pba:form-ui',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use(['ecmascript',   'mquandalle:jade@0.4.9', 'templating','coffeescript', 'less','stevezhu:lodash@4.6.1']);
  api.use([
    'aldeed:template-extension@4.0.0',
    
    'pba:woofmark-template', 
    'pba:woofmark',
    'pba:megamark', 
    'pba:domador',
    'pba:horsey',
    'pba:horsey-template',
    'nemo64:bootstrap@3.3.5_2',

    
    'templates:forms@2.1.2',
    'reactive-var',
    
    'tracker',
    'reactive-dict',
    'pba:bringme-helpers',
    

    ], 'client')
  api.use([
    'check',
    'aldeed:simple-schema@1.5.3',
    'pba:remove-markdown',
    'tmeasday:check-npm-versions',
    //'meteorhacks:zones@1.6.0',
    'vsivsi:file-collection@1.3.2',
    'aldeed:autoform@5.8.1', 
    ],['client','server'])
  api.use(['kitchen-settings', 'pba:join'],['client', 'server']);
  api.use("cfs:standard-packages@0.5.9");
  api.use("cfs:ui@0.1.3");
  api.use("cfs:base-package",'client',{weak:true});
  


  api.use("ctjp:meteor-bootstrap-switch@3.3.1_5" , 'client',{weak:true});

  api.export('form_ui');
  api.addFiles([
    
    'exports.coffee',
    'share.coffee',
    'simple-schema/literals.coffee',  
    'simple-schema/schema_supplement.coffee',
    'simple-schema/autoforms.coffee',
    'simple-schema/id_fields.coffee',
    //'simple-schema/join.coffee',
    //'simple-schema/autocomplete.coffee',

    'simple-schema/draft-types.coffee', 
    /* 
      This duplicates the collection schemas,
      so take care to alter the schema before draft-types.coffee
    */ 


  ],['client','server']);

  api.addFiles([
    'settings.coffee',
    'form-group.coffee',
    'form-group.jade',
    'form-ui.jade', 
    'form-ui.coffee',  
    'templates_forms_customize.coffee',
    'woofmark.less', 
    'woofmark_strings.coffee',

    'debug_form_wrapper.jade',
    'debug_form_wrapper.coffee'
    
    ], ['client']);
  

  api.addFiles([
    'list.jade',
    'list.coffee',
    'link.jade',
    'link.coffee',
    'label.jade' ,
    'label.coffee',
    'elements.less',
    'form-help-block.jade',
    'form-help-block.coffee',
    'autocomplete.jade',
    'autocomplete.coffee',
    'switch.jade',
    'switch.coffee',
    'file_uploader.jade',
    'file_uploader.coffee'



    ].map(function(f){return "elements/"+f}), 'client');

  api.addFiles("publish.coffee", 'server');

});

