root = exports ? this

$ ->

  $("a[data-target='#map']").on 'shown.bs.tab', (e) ->
    
    map = L.map('map-canvas').setView [51.505, -0.09], 2
    L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.png', {
      attribution: null,
      subdomains: '1234',
      type: 'osm',
    }).addTo(map)

    for repository in gon.repositories
      latitude = repository['latitude']
      longitude  = repository['longitude']
      marker = L.marker([latitude, longitude]).addTo map
      marker.bindPopup repository['name']

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metric/:metric_id")
    sm = new ScoreMeter(".metric.score-meter", gon.score)
