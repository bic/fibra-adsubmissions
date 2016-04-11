_ = lodash
join=
  config:
    debug:true
    index: "_id" 
    collection_list: -> Meteor.Collection.getAll()
    collection_for_name: (collection)->  
      if typeof collection == 'string'
        Meteor.Collection.get(collection)
      else if join.config.debug and not (collection instanceof Meteor.Collection)
        console.warn "collection of unknown type", collection
        collection
      else
        collection
    schemas_for_collection: (collection) ->
      collection= join.config.collection_for_name collection
      if collection._c2?._simpleSchemas?
        collection._c2?._simpleSchemas
      else if collection._c2?._simpleSchema?
        ret =
          selector:{}
          schema:collection._c2._simpleSchema
        [ret]
      else 
        console.error "could not find simpleSchema for whatever this is [expected collection]", collection
    schema_defs_for_schemas: (schemas)->
      schema.schema.schema() for schema in schemas
    schema_for_doc: (collection, doc)->
      collection= join.config.collection_for_name collection
      collection.simpleSchema(doc)

    compile_query_val:(val, parent_doc)->
      if _.isFunction val
        return val parent_doc
    
    ###
    note that join.config.collection_invariants depends on get_invariants looking at it!
    ###
    collection_invariants:{}
    ###
    ## Returns invariant generators 
    ###
    get_invariants:(collection,schema_selector)->
      
      compile=(schema_selector)->
          $and= []
          if  schema = join.config.schema_for_doc(collection, schema_selector)
            Array::push.apply $and, 
              _(schema.schema())
                .pickBy (v,k)->v?.join?.invariant?
                .mapValues (v,k)-> 
                  if _.isFunction v.join.invariant
                    (doc,other...)-> 
                      v.join.invariant doc,collection,k, other...
                  else
                    #The invariant might be  a plain query object
                    v.join.invariant
                .value()
          if (collection_invariant = join.config.collection_invariants?[collection])?
            $and.unshift collection_invariant
          if join.config.global_invariant?
            $and.unshift join.config.global_invariant
          unless $and.length
            return 
          else
            return $and
      if schema_selector? 
        # selector was supplied, thus we can precompile the invariants
        #
        $and = compile(schema_selector)
        unless $and?.length
          return 
        return (doc,other...)-> $and.map (inv)-> 
          if _.isFunction(inv)
            inv.call this, doc, other...
          else
            inv
      else
        # postpone compilation if the document is the schema selector
        # this has some small performance degradation
        return (doc,other...)->
          $and = compile(doc)
          unless $and?.length
            return
          $and.map (inv)-> 
            if _.isFunction(inv)
              inv.call this, doc, other...
            else
              inv


    global_invariant:(publish_ctx, doc)->
      owner_account:publish_ctx?.userId
  
  ###
  helper to create an invariant which is only tested if the field exists
  ###  
  exists_invariant:(invariant_fn)->
    (doc,collection,field,other...)->
      if doc.field?
        invariant_fn.call this, doc,collection,field,other...




