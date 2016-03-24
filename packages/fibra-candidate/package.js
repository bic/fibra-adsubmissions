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
      'mrt:filesize@2.0.3'
      ], 'client')

  api.use(['pba:form-ui'], 'client');

  

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
  
  //page templates
  api.addPages([
    '_base',
    '_people_role_list',
    'basics',
    'credits',
    'contributing_companies',
    'presentation',
    'files_upload'
    ],
    'client', 'pages/submissions/edit/');
  api.addPages([
    'homePrivateSubmissions'
    ],'client', 'pages/submissions/list/')
  //components reused on pages
  api.addPages(['side_bar_btn'], 'client', 'components/');

});


