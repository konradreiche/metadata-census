root = exports ? this

$ ->

  # Initializes the record search
  #
  initRecordSearch = () ->
    options = { valueNames: ["name", "score"] }
    list = new List("record-search-results", options, [])
    $(".list").empty()

    $("#record-search-input").on "input", _.debounce((event) =>
      inputValue = $(event.target).val()
      inputValue = if /\S/.test(inputValue) then inputValue else '*'
      data = { query: inputValue }
      url = "/repository/#{gon.repository.name}/metadata"

      list.clear()
      $.getJSON url, data, (result) =>
        for document in result
          name = document.record.name
          score = (document[gon.metric].score * 100).toFixed(2)
          list.add({ name: name, score: "#{score}%" })
    , 500)

  if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score-meter", gon.score)
    initRecordSearch()
