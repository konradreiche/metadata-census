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

  if getPath(1) == 'repository'
    sm = new ScoreMeter(".repository.score.meter", gon.score)
    registerListener(sm)
  else if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score.meter", gon.score)
