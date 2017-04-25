_= lodash
Impersonate.Roles =
  userIsInRole: (user_id,roles)->
    if _.isString(roles)
      roles= [roles]
    return Meteor.users.isInRoles(user_id, roles)
