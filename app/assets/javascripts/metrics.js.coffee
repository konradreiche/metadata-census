root = exports ? this

$ ->
  if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score-meter", gon.score)
