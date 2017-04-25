Package.describe({
  name: 'pba:fibra-jury',
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
      'submissions'
    ],
    'client',
    'jury/'

    );
  api.addFiles([
    'submissions-publish.coffee'

  ], 'server' );
  /*api.addFiles([
    'styles.less'
    ]);
  */
  api.use(
    [ 
      'templating',
      'mquandalle:jade@0.4.9',
      'coffeescript',
      'less',
      'stevezhu:lodash@4.6.1'
    ]
    );
  api.use([
    'reactive-dict'
    ],
    'client');

});