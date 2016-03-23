Package.describe({
  name: 'pba:horsey',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'horsey':'3.0.0'
}); 
Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use();
  api.use([ 'cosmos:browserify@0.10.0'], 'client')
  api.addFiles(['horsey.browserify.js', 'horsey.css' ], 'client');
  api.export('horsey', 'client'); 

});