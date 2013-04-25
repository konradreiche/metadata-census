#= require leaflet
$ ->
  map = L.map('map').setView [51.505, -0.09], 2
  L.tileLayer('http://{s}.tile.cloudmade.com/aff7873cf13349fe803e6a003f5c62bc/997/256/{z}/{x}/{y}.png', {
    attribution: "Metadata Census",
    maxZoom: 18
  }).addTo(map)
