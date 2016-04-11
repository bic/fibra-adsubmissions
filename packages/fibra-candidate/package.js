Package.describe({
  name: 'pba:fibra-candidate',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'candidate pages for fibra',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use(['ecmascript',  'templating','coffeescript', 'less','underscore']);
  api.use([
      'aldeed:template-extension@4.0.0', 
      'reactive-var', 
      'mquandalle:jade@0.4.9',
      'templates:forms@2.1.2', //used for continue btn
      'mrt:filesize@2.0.3',
      'pba:woofmark-template',
      
      'momentjs:moment@2.9.0',
      'aldeed:autoform@5.8.1',
      'reactive-dict',
      'chhib:selectize-bootstrap-3@0.0.1',
      'comerc:autoform-selectize@2.2.5',
      'yogiben:autoform-file@0.4.2',
      'tracker',
      'iron:router@1.0.12',
      'peppelg:bootstrap-3-modal',
      ], 'client')
  api.use([
    'pba:form-ui',
    'aldeed:simple-schema@1.5.3',
    'stevezhu:lodash@4.6.1',])
  api.use('check', 'server')
  api.use([ 'pba:join'], 'client');

  

  api.addPages = function(names,where,prefix, extensions){
    if (typeof names === 'string') names=[names];
    extensions= extensions || [".jade",".coffee"]
    if (typeof extensions === 'string') extensions=[extensions];


    names.forEach( 
      function(name){
          api.addFiles(
            extensions.map(
              function(ext){ 
                return prefix+name+(ext&&ext||"")
              }), 
          where );
        });
  } 
  api.addFiles('woofmark-config.coffee', 'client')
  api.addFiles('global.less', 'client')
  
  //page templates
  api.addPages([
    '_base',
    '_people_role_list',
    'ss/_ss_base',
    'ss/basics',
    'ss/credits',
    'ss/contributing_companies',
    'ss/side_btns',
    'presentation',
    'ss/files_upload',
    'all_submissions',
    'ss/preview',
    'ss/afFormGroup'
    ],
    'client', 'pages/submissions/edit/');
  api.addPages([
    '_base',
    'basics',
    'credits',
    'contributing_companies',
    'files',
    'presentation',
    'preview_all',
    ], 'client', 'pages/submissions/preview/')
  api.addPages([
    'homePrivateSubmissions'
    ],'client', 'pages/submissions/list/')
  api.addPages([
    'settings'
    ],'client', 'pages/user/')
  api.addFiles('pages/user/settings_schema.coffee', ['client', 'server'])
  api.addPages([
    
    'ss/ss_submit_btn',
    'ss/ss_preview_btn',
    ],
    'client', 'pages/submissions/edit/',['.jade','.coffee']);
  api.addPages([
    'ss/afArrayField_fibra',
    'ss/afObjectField_fibra'
    ],
    'client', 'pages/submissions/edit/',['.html','.coffee']);
  
  api.addFiles('components/invoice_data/ss.coffee');
  api.addPages( 'view','client','components/invoice_data/');
  
  api.addFiles('components/submitting_entity/ss.coffee', 'client')
  api.addPages( 'view','client','components/submitting_entity/');

  api.addFiles('accounts-config.coffee', 'server')
  api.use('accounts-base', 'server')
  //components reused on pages
  api.addPages(['side_bar_btn'], 'client', 'components/');
  //footer content
  api.addPages(['footer'], 'client', 'components/');
  api.addAssets([
    "adc-ro.png",
    "iaa.png",
    "iqads.png",
    "ministerul-culturii.png",
    "uapr.png",
    ].map(function(N){return "components/footer_static/"+N;}), 'client');




});


