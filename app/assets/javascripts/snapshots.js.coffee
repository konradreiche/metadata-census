#= require spin.min

root = exports ? this

options =
  lines: 10
  length: 4
  width: 5
  radius: 12
  corners: 2
  rotate: 0
  direction: 1
  color: '#000'
  speed: 1.4
  trail: 60
  shadow: true
  hwaccel: false
  className: 'spinner'
  zIndex: 2e9
  top: 'auto'
  left: 'auto'

spinner = null
target = null

$ ->
  target = $(".distribution > .row > .col-md-12 > .spinner")
  spinner = new Spinner(options).spin(target[0])


if isPath("/repositories/:repository_id/snapshots/:snapshot_id")
  query = "/repositories/#{repositoryId}/snapshots/#{snapshotId}/distribution"
  $.getJSON query, (distribution) ->
    $ ->
      spinner.stop()
      target.remove()
      new Histogram("#quality-distribution", distribution, [0, 100])

initWeightSlider = (sm) ->
  weightScores(sm)
  $(".weight-slider").on "change", (event) ->
    value = $(this).val()
    $(this).parents("td").find("span").text(value)
    weightScores(sm)

##
#
##
weightScores = (scoreMeter) ->

  weightings = {}

  scores = []
  weights = []

  $(".weight-slider").each () ->
    weight = parseInt $(this).val()
    metric = $(this).data("metric")

    weightings[metric] = weight

    if gon.snapshot[metric]?
      scores.push(gon.snapshot[metric]["average"] * weight)
      weights.push(weight)
    else
      scores.push(0.0)
      weights.push(weight)

  score = scores.reduce (t, s) -> t + s
  max = weights.reduce (t, s) -> t + s

  result = if max == 0 then 0.0 else score / max
  scoreMeter.update(result)

  $.post "/repositories/weighting", { weightings: weightings }

$ ->

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id")
    sm = new ScoreMeter(".repository.score-meter", gon.snapshot.score)
    initWeightSlider(sm)
