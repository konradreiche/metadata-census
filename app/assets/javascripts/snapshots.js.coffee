root = exports ? this

if isPath("/repositories/:repository_id/snapshots/:snapshot_id")
  query = "/repositories/#{repositoryId}/snapshots/#{snapshotId}/distribution"
  target = ".distribution-dashboard > .row > .col-md-12 > .spinner"
  loadData query, null, target, (distribution) ->
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
