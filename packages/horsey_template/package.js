Package.describe({
  name: 'pba:horsey-template',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'input templates for horsey',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use(['ecmascript',  'templating','coffeescript', 'less','underscore']);
  api.use(['aldeed:template-extension@4.0.0','pba:horsey', 'reactive-var', 'mquandalle:jade@0.4.9'], 'client')
  api.addFiles(['horsey-template.jade','horsey-template.coffee' ], 'client');
});

