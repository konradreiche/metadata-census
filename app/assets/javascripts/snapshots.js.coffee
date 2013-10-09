root = exports ? this

$ ->

  ##
  #
  ##
  initWeightSlider = (sm) ->
    $(".weight-slider").on "change", (event) ->
      value = $(this).val()
      $(this).parents("td").find("span").html("#{value}&times;")
      weightScores(sm)

  ##
  #
  ##
  weightScores = (scoreMeter) ->

    scores = []
    weights = []

    $(".weight-slider").each () ->
      weight = parseInt $(this).val()
      metric = $(this).data("metric")

      if gon.snapshot[metric]?
        scores.push(gon.snapshot[metric]["average"] * weight)
        weights.push(weight)
      else
        scores.push(0.0)
        weights.push(weight)

    score = scores.reduce (t, s) -> t + s
    max = weights.reduce (t, s) -> t + s
    scoreMeter.update(score / max)
 

  if isPath("/repositories/#{repositoryId}/snapshots/#{snapshotId}")
    sm = new ScoreMeter(".repository.score-meter", gon.score)
    initWeightSlider(sm)
