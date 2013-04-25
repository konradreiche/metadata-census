#= require leaflet
$ ->

  map = L.map('map').setView [51.505, -0.09], 2
  L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.png', {
    attribution: null,
    subdomains: '1234',
    type: 'osm',
  }).addTo(map)
