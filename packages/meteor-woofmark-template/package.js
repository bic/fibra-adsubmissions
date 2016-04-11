Package.describe({
  name: 'pba:woofmark-template',
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
  api.use(['ecmascript',  'templating','coffeescript', 'less','underscore']);
  api.use(['aldeed:template-extension@4.0.0','pba:woofmark', 'reactive-var'], 'client');
  api.addFiles(['woofmark-textarea.html','woofmark-textarea.coffee' ], 'client');
  api.use(['pba:megamark', 'pba:domador','pba:remove-markdown'] , 'client', {weak:true});
  api.imply('pba:woofmark', 'client');
});

