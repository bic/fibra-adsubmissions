
share.jurors =[
    
    {
      "id" : "c6aDhihm3ZHrRcYfg",
      "name" : "Kevin Brady – Droga5"
      initial: "B"
    },
    {
      "id" : "P7fpvibNaEeKC8yQY",
      "name" : "Wendy Richardson – 72 and sunny"
      initial: "R"
    },
    {
      "id" : "9tptM3k7PouZTSwWr",
      "name" : "Robert Nagy –  Heavy"
      initial: "N"
    },
    {
      "id" : "dSwydf3Z4BPbeFAGx",
      "name" : "Olivia Walsh – Apple Tree Communications"
      initial: "W"
    },
    {
      "id" : "MXMpwmtuBeqfk6dCF",
      "name" : "Bruno Luglio – R/GA, New York"
      initial: "L"
    },
    {
      "id" : "KkRLqbpKuf7FNdz3z",
      "name" : "Radinka Danilov - Ruskin & Hunt"
      initial: "D"
    },
    {
      "id" : "67BPkKW5LCKfZ633M",
      "name" : "Evgeny Primachenko – Wieden+Kennedy"
      initial: "П"
    },
    { 
      "id": "fqsjxb7grjNJSReee"
      "name": "Karpat Polat – Karpat"
      initial: "P"
    }
  ]
unless Meteor.settings.production
  share.jurors.push
      "id" : "SfuPntkiWHRfQ2fEM"
      "name" : "Paul test account"
      initial: "X"
    

@Stats=Stats= new Meteor.Collection 'stats'