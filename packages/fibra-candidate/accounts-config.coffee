_= lodash
Meteor.startup ->
  _.extend Accounts.emailTemplates, 
    from:"contact@iqads.ro"
    siteName: "adsubmission.premiilefibra.ro"

