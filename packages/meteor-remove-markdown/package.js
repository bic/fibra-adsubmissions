Package.describe({
  name: 'pba:remove-markdown',
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
  'remove-markdown':'0.1.0'
}); 
Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use();
  api.use([ 'cosmos:browserify@0.10.0'], 'client')
  api.addFiles(['remove-markdown.browserify.js' ], ['client']);
  api.addFiles(['server.js' ], [ 'server']);
  api.export('removeMd'); 

});