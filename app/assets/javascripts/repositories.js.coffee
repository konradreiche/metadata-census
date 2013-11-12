root = exports ? this

$ ->

  $("a[data-target='#map']").on 'shown.bs.tab', (e) ->

    scoreControlCommand = () ->
      alert("Working")

    map = L.map('map-canvas').setView [51.505, -0.09], 2
    L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.png', {
      attribution: null,
      subdomains: '1234',
      type: 'osm',
    }).addTo(map)

    L.Control.Command = L.Control.extend({
      options: {
        position: "topleft"
      },
      onAdd: (map) ->
        controlDiv = L.DomUtil.create("div", "leaflet-control-command")
        L.DomEvent
          .addListener(controlDiv, "click", L.DomEvent.stopPropagation)
          .addListener(controlDiv, "click", L.DomEvent.preventDefault)
          .addListener(controlDiv, "click", () -> scoreControlCommand())

        controlInterface = L.DomUtil.create("div", "leaflet-control-score-interior", controlDiv)
        controlInterface.title = "Toggle Scores"
        controlButton = L.DomUtil.create("a", "control-link glyphicon glyphicon-dashboard", controlInterface)

        return controlDiv
    })
     
    scoreControl = new L.Control.Command({})
    map.addControl(scoreControl)

    for repository in gon.repositories
      latitude = repository['latitude']
      longitude  = repository['longitude']
      marker = L.marker([latitude, longitude]).addTo map
      marker.bindPopup repository['name']

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metric/:metric_id")
    sm = new ScoreMeter(".metric.score-meter", gon.score)
