#= require leaflet
root = exports ? this

# Update the metric scores according to the weighting
registerListener = (scoreMeter) ->
  $("#weighting-modal").on "hidden.bs.modal", () =>
    weighting = {}
    for metric in gon.metrics
      weight = $("input[id^=#{metric}]").val()
      if not not weight  # input field empty?
        weighting[metric] = weight
    $.getJSON "#{window.location.pathname}/score", weighting, (score) =>
      scoreMeter.update(score)

$ ->

  if $(".repositories.map").length
    
    map = L.map('map').setView [51.505, -0.09], 2
    L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.png', {
      attribution: null,
      subdomains: '1234',
      type: 'osm',
    }).addTo map

    for repository in gon.repositories
      latitude = repository['latitude']
      longitude  = repository['longitude']
      marker = L.marker([latitude, longitude]).addTo map
      marker.bindPopup repository['name']

  if getPath(1) == 'repositories'
    sm = new ScoreMeter(".repository.score-meter", gon.score)
    registerListener(sm)
  else if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score-meter", gon.score)
