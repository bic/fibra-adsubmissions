Package.describe({
  name: 'pba:fibra-kitchen-customizer',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'userland glue for kitchen-generated parts ',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});
Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  api.use([
    'coffeescript',
    'stevezhu:lodash@4.6.1',
    'pba:join',
    'check'
    ]
    , 
    ['client','server']);
  api.addFiles([
    'bugs.coffee',
    'route_subscriptions.coffee'
    ], ['client','server']);
  api.addFiles(['fixtures.coffee'], 'server');
});
