
_= lodash


###
Function to generate a treepublish configuration for schemas with join definitions
@param `collection`: string reference to a collection which possibly contains links
The algorithm does a breadth-first traversal of the reference tree.
- links to the same 


```
lvl 1               A
          ---------------------
lvl 2     B            C      B
          ------     -------  -
lvl 3     E    D     A C B D  C
          ---  - 
lvl 4     F D  X
```
What will be included(collections are Letters, and the level is how deeply they are nested):
publish_composite_query "A":

- `A1`: find-> you are free to define this function 
  - `B2`(both links): are included. Links defined on a collection can point to the same collection multiple times
  - `C2`: included
    -`E3`: included
      - `F4`: included
      - `D4`: excluded, conflits with `D3` (the first, child of `B2`)
    -`D3` first (child of B2, first): included
      - `X4`: included
    -`A3`: conflicts with A1, not included
    -`C3`: conflicts with C2, not included
    -`B3`: conflicts with any of the 2 `B2`
    -`D3` second(child of C): conflicts with D3 first
    -`C3`: conflicts with `C2`

###
 
compile_selector = (invariants, publish_context,parent_docs...)->
  ret= do=>
    $or= []
    ## hash object is used to remove duplicates
    hash= {}
    queries_by_keys={}
    for query in @queries
      q= query(publish_context,parent_docs...)
      if q?
        str = JSON.stringify q
        unless hash[str]
          hash[str]=true
          $or.push(q)
    if $or.length
      if $or.length == 1
        return $or[0]
      else
        return {$or:$or}
    else
      return

  if ret? and invariants?
    ret=
      $and:[invariants(publish_context,parent_docs...)..., ret ]
  else if invariants?
    return {$and:invariants(parent_docs...)}
  else if ret?
    return ret
  else
    return 
recursive_get_ids = (doc,key_parts)->
  if  not doc?
    return
  else if key_parts.length == 0
    return doc
  else if key_parts[0]=="$"
    if _.isArray(doc)
      key_parts = key_parts[1...]
      return _.flatten( recursive_get_ids(doc[i], key_parts) for i in [0...doc.length] )
  else
    val = _.get doc,key_parts[0]
    return recursive_get_ids val, key_parts[1...]
build_query= (target_key, source_key)->
  index = join.config.index
  s_key_parts = source_key.split('.')
  if '$' in source_key
    tmp = s_key_parts
    s_key_parts= []
    while (i= tmp.indexOf('$'))>-1
      s_key_parts.push tmp[0...i].join("."), "$"
      tmp.splice(0,i+1)
    s_key_parts.push tmp...

    (parent_doc)-> 

      tmp = recursive_get_ids parent_doc, s_key_parts
      if tmp?
        ret= {}
        ret[target_key]=
          $in: tmp
        console.log("expecting key #{source_key}, parent_doc= #{JSON.stringify parent_doc} , returning #{JSON.stringify ret}") 
        return ret 
      else
        return
  else

    (parent_doc)->
      ret = {}
      
      ret[index]= _.get parent_doc, s_key_parts
      if ret[index]?
        return ret
      else 
        # no link present
        return

join.publish_composite_query = (initial_collection,options)->
  [
    index ,
    collection_for_name, 
    schemas_for_collection,
    collection_list, 
    schema_defs_for_schemas
    compile_query_val,
    get_invariants
    ] =  _.values _.pick join.config, 
      "index,collection_for_name,schemas_for_collection,collection_list,schema_defs_for_schemas,compile_query_val,get_invariants".split ","
  references={}
  
  if _.isFunction options
    options=
      query:options
  _.defaults options,
    use_invariant: not options?.find?
  ## the initial find is mandatory
  check options, Match.OneOf (Match.ObjectIncluding {query: Match.OneOf Function, Object}),
    Match.ObjectIncluding
      find:Function
  root_ctx = 
    collection: initial_collection
  if options.query?
    _.extend root_ctx , 
      queries: [options.query]
      compile_selector: compile_selector.bind root_ctx, get_invariants initial_collection , options.schema_selector
      find : (params...)->
        try
          return collection_for_name(initial_collection).find root_ctx.compile_selector this, params...
        catch e
          unless options.schema_selector
            console?.warn "you can supply a schema_selector to publish_composite_query"
          throw e
        
  else if options.find
    if options.use_invariants
      throw new Error "use_invariants cannot be used with a user supplied find function. Please either check yourself the invariants, or supply a query option instead"
   
    _.extend root_ctx, 
      find: options.find
  else
    _.extend root_ctx,
      find: (params...)->
        #just return all documents
        return collection_for_name(initial_collection).find this, params...
  link_collections = (collection_ref)->
    collection=collection_ref.collection
    level_references= {}
    references[collection]?=collection_ref
    ret = []
    col_obj= collection_for_name collection
    publish_subtree = schema_defs_for_schemas(schemas_for_collection(col_obj)).map (schema)->   
      _(schema)
        .pickBy (v,k)->v.join?.collection
        .transform (res, v,k)->
            unless  references[v.join.collection]?
              unless res[v.join.collection]?
                  link_col_obj=collection_for_name(v.join.collection)
                  res[v.join.collection] = 
                    queries:[]
                    collection: v.join.collection
                  

                  res[v.join.collection].find= do(composite_config = res[v.join.collection], join_collection= v.join.collection)->
                        (parent_docs...)->
                          selector = composite_config.compile_selector( this, parent_docs...)
                          col= collection_for_name join_collection
                          return col.find(selector)

                  res[v.join.collection].compile_selector= compile_selector.bind res[v.join.collection], get_invariants collection

                  references[collection].children?=[]
                  references[collection].children.push res[v.join.collection]
              res[v.join.collection].queries.push do ->
                default_query = build_query(index,k)
                (parent_doc)->
                  unless v.join.query?
                    return default_query(parent_doc)
                  if _.isFunction v.join.query
                    return  v.join.query parent_doc
                  else
                    _.cloneDeepWith v.join.query, (value,key,object)->
                      #todo: offer full path to compile_query_key
                      if val = compile_query_val(value, parent_doc)
                        return val
                      #default copy method if not
                      return
            return res

          ,
          level_references
        .value()
    #_.extend references, level_references
    return _.values(level_references)
  process = (collection) ->
    queue = [
      collection
      null
    ]
    i = 0
    n = 1
    while queue[i] != null or i == 0 or queue[i - 1] != null
      if queue[i] == null
        queue.push null
      else
        queue[i].n = n++
        link_collections(queue[i]).forEach (link_collection) ->
          queue.push link_collection
          return
      i++
    return


  process root_ctx
    
  return references[initial_collection]

# ---
# generated by js2coffee 2.1.0


  

