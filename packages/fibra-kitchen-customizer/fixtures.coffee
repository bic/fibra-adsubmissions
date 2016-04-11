cats = 
  'VIDEO':
    'nr': '1'
    'sections': [
      {
        'cat': '1'
        'nr': '1'
        'title': 'TV/ Cinema'
      }
      {
        'cat': '1'
        'nr': '2'
        'title': 'Online'
      }
      {
        'cat': '1'
        'nr': '3'
        'title': 'Viral'
      }
      {
        'cat': '1'
        'nr': '4'
        'title': 'Branded Content & Entertainment'
      }
      {
        'cat': '1'
        'nr': '5'
        'title': 'Other Screens & Events'
      }
    ]
  'RADIO':
    'nr': '2'
    'sections': []
  'PRINT':
    'nr': '3'
    'sections': [
      {
        'cat': '3'
        'nr': '1'
        'title': 'Press'
      }
      {
        'cat': '3'
        'nr': '2'
        'title': 'Indoor & In-store'
      }
      {
        'cat': '3'
        'nr': '3'
        'title': 'Publications and Brand Collateral'
      }
      {
        'cat': '3'
        'nr': '4'
        'title': 'Packaging'
      }
      {
        'cat': '3'
        'nr': '5'
        'title': 'Brand identity'
      }
    ]
  'CRAFT':
    'nr': '4'
    'sections': [
      {
        'cat': '4'
        'nr': '1'
        'title': 'Best Art Direction'
      }
      {
        'cat': '4'
        'nr': '2'
        'title': 'Best Illustration'
      }
      {
        'cat': '4'
        'nr': '3'
        'title': 'Best Copywriting'
      }
      {
        'cat': '4'
        'nr': '4'
        'title': 'Film Craft'
      }
      {
        'cat': '4'
        'nr': '5'
        'title': 'Sound Design'
      }
    ]
  'DIGITAL':
    'nr': '5'
    'sections': [
      {
        'cat': '5'
        'nr': '1'
        'title': 'Web'
      }
      {
        'cat': '5'
        'nr': '2'
        'title': 'Branded Games'
      }
      {
        'cat': '5'
        'nr': '3'
        'title': 'Branded Apps'
      }
      {
        'cat': '5'
        'nr': '4'
        'title': 'Branded Tech'
      }
      {
        'cat': '5'
        'nr': '5'
        'title': 'Social Media'
      }
      {
        'cat': '5'
        'nr': '6'
        'title': 'Online Banners'
      }
    ]
  'INTEGRATED':
    'nr': '6'
    'sections': []
  'MEDIA':
    'nr': '7'
    'sections': [
      {
        'cat': '7'
        'nr': '1'
        'title': 'Creative Use of Media'
      }
      {
        'cat': '7'
        'nr': '2'
        'title': 'Creative Media Mix'
      }
    ]
  'OUTDOOR':
    'nr': '8'
    'sections': [
      {
        'cat': '8'
        'nr': '1'
        'title': 'Billboard and Outdoor Poster'
      }
      {
        'cat': '8'
        'nr': '2'
        'title': 'Special Projects'
      }
    ]
  'NON-PROFIT':
    'nr': '9'
    'sections': []
  'PR':
    'nr': '10'
    'sections': [
      {
        'cat': '10'
        'nr': '1'
        'title': 'Corporate Communications'
      }
      {
        'cat': '10'
        'nr': '2'
        'title': 'Media Relations'
      }
      {
        'cat': '10'
        'nr': '3'
        'title': 'Sponsorship, Partnership & Endorsements'
      }
      {
        'cat': '10'
        'nr': '4'
        'title': 'Experiential/ Stunts'
      }
    ]
  'PROMO & ACTIVATION':
    'nr': '11'
    'sections': [
      {
        'cat': '11'
        'nr': '1'
        'title': 'Brand Activation'
      }
      {
        'cat': '11'
        'nr': '2'
        'title': 'Shopper Experience'
      }
      {
        'cat': '11'
        'nr': '3'
        'title': 'Brand Promotions'
      }
    ]
  'PRODUCT DESIGN':
    'nr': '12'
    'sections': []
  'DIRECT MARKETING':
    'nr': '13'
    'sections': [
      {
        'cat': '13'
        'nr': '1'
        'title': 'Use of Traditional Media for Direct Marketing'
      }
      {
        'cat': '13'
        'nr': '2'
        'title': 'Use of New Media for Direct Marketing'
      }
    ]
  'EVENTS':
    'nr': '14'
    'sections': [
      {
        'cat': '14'
        'nr': '1'
        'title': 'Live Shows & Festivals'
      }
      {
        'cat': '14'
        'nr': '2'
        'title': 'Learning and Exhibition'
      }
      {
        'cat': '14'
        'nr': '3'
        'title': 'Corporate Entertainment'
      }
    ]
Meteor.startup ->
  for cat_name,def of cats
    db_cat= Categories.findOne({name:cat_name})
    cat=
      draft:false
      name:cat_name
      number:def.nr
    unless db_cat
      cat._id= Categories.insert cat 
    else
      Categories.update db_cat._id,
        $set: cat
      cat._id = db_cat._id

    unless def?.sections?.length
      console.error "Sections missing in fixture category #{cat_name}: defintion:", def
      if def?.sections?
        def.sections.push
          cat: def.nr
          nr: "1"
          title: cat_name
        console.warn "Autoadded: ", def.sections[0] 
    else
      counter=
        update:0
        insert:0
      for sec_def in def.sections
        sec=
          draft:false
          name:"#{def.nr}.#{sec_def.nr} #{cat_name} - #{sec_def.title}"
          category_id: cat._id
        unless db_sec= Sections.findOne {name: sec.name}
          sec._id = Sections.insert sec
          counter.insert++
        else Sections.update db_sec._id,
          $set: _.omit sec, '_id'
          counter.update++
        console.log ("Sections: #{counter.update} updated, #{counter.insert} inserted.")



# ---
# generated by js2coffee 2.1.0