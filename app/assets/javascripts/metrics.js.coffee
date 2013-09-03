root = exports ? this

$ ->

  recordSelectionLink = (current, next) ->
    documents = (document.id for document in gon.documents)
    documents[documents.indexOf(current)] = next
    parameter = ({ name: "documents[]", value: id } for id in documents)
    query = decodeURIComponent($.param(parameter))
    "?#{query}"

  # Initializes the record search
  #
  initRecordSearch = (i) ->
    options = { valueNames: ["name", "score"] }
    selector = "record-search-results-#{i}"
    list = new List(selector, options, [])
    $("##{selector}").find($(".list")).empty()

    $("#record-search-input-#{i}").on "input", _.debounce((event) =>
      inputValue = $(event.target).val()
      inputValue = if /\S/.test(inputValue) then inputValue else '*'
      data = { query: inputValue }
      url = "/repository/#{gon.repository.name}/metadata"

      list.clear()
      $.getJSON url, data, (result) =>
        for document in result
          name = document.record.name
          score = (document[gon.metric].score * 100).toFixed(2)
          id = document.id
          list.add({ name: name, score: "#{score}%", id: id })

        # add row link feature
        $(".list > tr").addClass("rowlink")
        $(".list > tr > td").addClass("nolink")
        current = $("#record-search-results-#{i}").data("document")
        for item in list.items
          text = $(item.elm).children("td:first-child").contents()
          attributes = { href: recordSelectionLink(current, item.values().id) }
          text.wrap($("<a>", attributes))
    , 500)

  if getPath(2) == 'metric'
    sm = new ScoreMeter(".metric.score-meter", gon.score)
    initRecordSearch(i) for i in [0..1]
