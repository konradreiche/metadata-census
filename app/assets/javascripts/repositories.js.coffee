root = exports ? this

$ ->

  class RepositoryMap

    TILE_URL = "http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.png"

    constructor: (target) ->
      @map = L.map(target).setView([51.505, -0.09], 2)
      options = {attribution: null, subdomains: "1234", type: "osm"}
      L.tileLayer(TILE_URL, options).addTo(@map)

      markers = @initMarkers()
      @initControls(markers)

    initControls: (markers) ->
      toggleMarkerIcons = @toggleMarkerIconsFunc(markers)

      onAdd = (map) ->
        controlDiv = L.DomUtil.create("div", "leaflet-control-command")
        L.DomEvent
          .addListener(controlDiv, "click", L.DomEvent.stopPropagation)
          .addListener(controlDiv, "click", L.DomEvent.preventDefault)
          .addListener(controlDiv, "click", () -> toggleMarkerIcons())

        controlUiClass = "leaflet-control-score-interior"
        controlUi = L.DomUtil.create("div", controlUiClass, controlDiv)
        controlUi.title = "Toggle Scores"

        controlButtonClass = "control-link glyphicon glyphicon-dashboard"
        controlButton = L.DomUtil.create("a", controlButtonClass, controlUi)

        return controlDiv

      options = { position: "topleft" }
      L.Control.Command = L.Control.extend({ options: options, onAdd: onAdd })
     
      scoreControl = new L.Control.Command({})
      @map.addControl(scoreControl)

    initMarkers: () ->
      markers = []

      for repository in gon.repositories
        score = calculateScore(repository)
        latitude = repository['latitude']
        longitude  = repository['longitude']

        marker = L.marker([latitude, longitude], {icon: @getScoreIcon(score)}).addTo(@map)
        marker.bindPopup(repository['name'])
        markers.push(marker)

      return markers

    toggleMarkerIconsFunc: (markers) ->
      return () ->
        for marker in markers
          console.log marker

    getScoreIcon: (score) ->
      if score == null
        markerClass = "marker-score-unknown"
      else if score >= 0.0 <= 0.29
        markerClass = "marker-score-low"
      else if score >= 0.3 <= 0.69
        markerClass = "marker-score-medium"
      else if score >= 0.7 <= 1.00
        markerClass = "marker-score-high"

      score = if score then Math.round(score * 100) else "-"
      options = {
        className: "marker-score #{markerClass}",
        html: "<div><strong>#{score}</strong></div>",
        iconSize: [50, 50]
      }
      
      L.divIcon(options)

  $("a[data-target='#map']").on 'shown.bs.tab', (e) ->
    new RepositoryMap("map-canvas")

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metric/:metric_id")
    sm = new ScoreMeter(".metric.score-meter", gon.score)
