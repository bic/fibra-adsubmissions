

@SubmissionFiles2= SubmissionFiles2 = new FileCollection('submission_files2',
    resumable: true
    http: [ {
      method: 'get'
      path: '/:md5'
      lookup: (params, query) ->
        # uses express style url params
        { md5: params.md5 }
        # a query mapping url to myFiles

    } ])

if Meteor.isServer
  Meteor.publish 'submission_files2', (clientUserId) ->
    if clientUserId == @userId
      SubmissionFiles2.find
        'metadata._Resumable': $exists: false
        'metadata.owner_account': @userId
    else
      # Prevent client race condition:
      null
      # This is triggered when publish is rerun with a new
      # userId before client has resubscribed with that userId
  @SubmissionFiles2.allow
    insert: (userId, file) ->
      # Assign the proper owner when a file is created
      file.metadata?={}
      file.metadata.owner_account = userId
      true
    remove: (userId, file) ->
      # Only owners can delete
      userId == file.metadata.owner_account
    read: (userId, file) ->
      userId == file.metadata.owner_account
    write: (userId, file, fields) ->
      # Only owners can upload file data
      userId == file.metadata.owner_account
else #client
  Meteor.startup ->
    # This assigns a file upload drop zone to some DOM node
    SubmissionFiles2.resumable.assignDrop $('.fileDrop')
    # This assigns a browse action to a DOM node
    SubmissionFiles2.resumable.assignBrowse $('.fileBrowse')
    # When a file is added via drag and drop
    SubmissionFiles2.resumable.on 'fileAdded', (file) ->
      # Create a new file in the file collection to upload
      SubmissionFiles2.insert {
        _id: file.uniqueIdentifier
        filename: file.fileName
        contentType: file.file.type
      }, (err, _id) ->
        # Callback to .insert
        if err
          return console.error('File creation failed!', err)
        # Once the file exists on the server, start uploading
        SubmissionFiles2.resumable.upload()
        return
      return
    # This autorun keeps a cookie up-to-date with the Meteor Auth token
    # of the logged-in user. This is needed so that the read/write allow
    # rules on the server can verify the userId of each HTTP request.
    Deps.autorun ->
      # Sending userId prevents a race condition
      Meteor.subscribe 'submission_files2', Meteor.userId()
      # $.cookie() assumes use of "jquery-cookie" Atmosphere package.
      # You can use any other cookie package you may prefer...
      $.cookie 'X-Auth-Token', Accounts._storedLoginToken()
      return
    return
