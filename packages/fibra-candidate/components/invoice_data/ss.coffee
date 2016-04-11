_= lodash
SimpleSchema.messages
  cui_not_valid:"This is not a valid Romanian CUI/CIF"

form_ui.validare_cif = (s) ->
  if parseInt(s).toString() != s
    if s.substring(0, 2).toUpperCase() != 'RO' or s.length > 12
      return false
    s = s.substring(2, s.length)
    #Extract only the numeric content
  else
    if s.length > 10
      return false
  cifraControl = parseInt(s.charAt(s.length - 1))
  content = s.substring(0, s.length - 1)
  while content.length < 9
    content = '0' + content
  suma = content.charAt(0) * 7 + content.charAt(1) * 5 + content.charAt(2) * 3 + content.charAt(3) * 2 + content.charAt(4) * 1 + content.charAt(5) * 7 + content.charAt(6) * 5 + content.charAt(7) * 3 + content.charAt(8) * 2
  suma = suma * 10
  rest = suma % 11
  if rest == 10
    rest = 0
  if rest == cifraControl
    true
  else
    false


if Meteor.isServer
  company_cache= new Meteor.Collection('company_cache')
  source_keys = ['updated_at','created_at']
  Meteor.methods
    ro_company_info: (cui)->
      check(cui,  String)
      unless form_ui.validare_cif cui
        throw new Meteor.Error 'cui_not_valid', "Cui does not appear to be in a valid romanian CUI/CIF format."
      if /RO\d+/i.exec(cui)
        cui = cui[2...]
      if cached= company_cache.findOne({cif:cui})
        return cached
      else
        {Client} = require('node-rest-client')
        Client= new Client()
        func = Meteor.wrapAsync (uri, cb)->
          Client.get uri, Meteor.bindEnvironment (data,response)-> 
            if data?
              data.source = 
                uri:uri
              _.extend(data.source , _.pick(data, source_keys))
              data = _.omit(data, source_keys)
              id = company_cache.insert(data)
              data = company_cache.findOne(id)
            cb(undefined, data) 
        #console.log func, Client
        ret = func "http://openapi.ro/api/companies/#{cui}.json"
        console.log "company data:",  JSON.stringify(ret)
        return ret

