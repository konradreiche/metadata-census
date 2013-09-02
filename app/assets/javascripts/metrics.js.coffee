root = exports ? this

$ ->
  tableFilter = () ->
    $("#record-search-input").on "input", (event) ->
      rows = $(".table.metric.record-results > tbody > tr")
      rows.hide()
      rows.filter(":contains(#{$(this).val()})").show()

  if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score-meter", gon.score)
    tableFilter()
