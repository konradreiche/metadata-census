root = exports ? this

$ ->
  tableFilter = () ->
    $("#record-search-input").on "input", (event) ->

      options =
        valueNames: ["name", "score"]
      data =
        query: $(this).val()

      values = []
      url = "/repository/#{gon.repository.name}/metadata"

      $.getJSON url, data, (result) ->
        for document in result
          console.log document
          values.push({ name: document.record.name, score: document[gon.metric].score })

      console.log values
      resultList = new List("results", options, values)
      #rows = $(".table.metric.record-results > tbody > tr")

  if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score-meter", gon.score)
    tableFilter()
