Package.describe({
  name: 'pba:join',
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
  //api.use();
  api.use([ 'reywood:publish-composite@1.4.2'], 'server')
  api.use([ 'coffeescript', 'stevezhu:lodash@4.6.1', 'check'], ['client', 'server'] ) // remove this dependency and use own code
  api.use([ 'dburles:mongo-collection-instances@0.3.5'], ['client', 'server'] ) //make this a weak dependency

  api.use([])
  api.addFiles(['exports.coffee' ,'publish.coffee'], ['client', 'server']); // remove the client part if not developing
  api.export('join', ['client', 'server']); 

});

