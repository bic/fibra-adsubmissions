Package.describe({
  name: 'kitchen-settings',
});
Package.onUse(function(api) {
  api.addFiles(['kitchen-settings.js' ]);
  api.addAssets(['application.json'],['client','server']);
  api.use (['underscore'], 'server');
  api.use (['tracker', 'ejson', 'underscore'], 'client');

  api.export('app_json');
});

