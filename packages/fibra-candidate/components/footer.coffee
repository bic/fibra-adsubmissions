
do(tmpl=Template.fibra_footer)->
  helpers=
    image_urls: (inst)->
      ["iqads.png",
       "iaa.png",
       "uapr.png",
       "adc-ro.png",
        "ministerul-culturii.png"
      ].map (name)->
        return "/packages/pba_fibra-candidate/components/footer_static/#{name}"
  tmpl.instance_helpers helpers
