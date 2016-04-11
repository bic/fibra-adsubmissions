
if(Meteor.isServer)
{

  app_json= JSON.parse(Assets.getText('application.json'));
  var _orig_app_json = _.extend({} , app_json);
  app_json.get = function(){return app_json;}
  app_json.isReady = function(){return true}
  Meteor.methods({
    'get_app_json':function() { 
      return _orig_app_json;
    }
  });
} else if (Meteor.isClient) {
  dep = new Tracker.Dependency;

  app_json={
    isReady: function(){
      //Reactive ready method
      dep.depend();
      return _.isObject( app_json.application);
    },
    get: function() {
      //Reactive get method
      dep.depend();
      return app_json.application;
    }
  }
  Meteor.call('get_app_json', function(error,result){
    if(error){
      console.error("kitchen-settings: error getting app_json: ", error )
      return
    }
    var call_changed=false
    if(dep.hasDependents()){
      if(!EJSON.equals( result.application, app_json.application)) {
         call_changed=true;
      }
    }
    _.extend(app_json,result)
    if(call_changed) dep.changed();

  });
  
}