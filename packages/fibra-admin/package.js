Package.describe({
  name: 'pba:fibra-admin',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'candidate pages for fibra',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});
Package.onUse(function(api){
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
  api.addPages(
    [
      'accounts',
      'submissions',
      'field_selector',
      'review_box',
      'impersonate_btns',
    ],
    'client',
    'admin/'

    );
   api.addPages(
    [
      'submissions',
      'grading_widget',
      'evaluation',
    ],
    'client',
    'jury/'

    );
  api.addFiles('jury/stats_collection.coffee'); 
  api.addFiles([
    'accounts-publish.coffee',
    'impersonate-settings.coffee',
    'jury/flow_publications.coffee',
    'section_count.coffee'
  ], 'server' );

  api.addFiles([
    'styles.less',
    'jury/grading-widget.less'
    ]);

  api.use(
    [ 
      'templating',
      'mquandalle:jade@0.4.9',
      'coffeescript',
      'less',
      'stevezhu:lodash@4.6.1',
      'gwendall:impersonate@0.2.3'

    ]
    );
  api.use([
    'reactive-dict',
    'reactive-var',
    'session',
    'peppelg:bootstrap-3-modal',    
    ],
    'client');
  api.use('email', 'server')
  api.addFiles('notification_emails.coffee', ['server', 'client'])

});