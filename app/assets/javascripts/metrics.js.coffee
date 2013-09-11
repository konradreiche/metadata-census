root = exports ? this

$ ->

  ##
  # Sets up the pie chart for the statistics tab
  #
  initPieChart = () ->

    width = 960
    height = 500
    radius = Math.min(width, height) / 2

    color = d3.scale.ordinal().range(["#98abc5", "#8a89a6", "#7b6888",
      "#6b486b", "#a05d56", "#d0743c", "#ff8c00"])

    arc = d3.svg.arc()
      .outerRadius(radius - 10)
      .innerRadius(0)

    pie = d3.layout.pie()
      .sort(null)
      .value((d) -> return d.value)

    svg = d3.select("#statistics").append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

    d3.csv "data.csv", (error, data) =>
      values = (+ value for value in data.values)

      g = svg.selectAll(".arc")
        .data(pie(data))
        .enter().append("g")
        .attr("class", "arc")

      g.append("path")
        .attr("d", arc)
        .style("fill", (d) -> return color(d.data.key))

      g.append("text")
        .attr("transform", (d) -> return "translate(#{arc.centroid(d)})")
        .attr("dy", ".35em")
        .style("text-anchor", "middle")
        .text((d) -> return d.data.key)
      

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
    initPieChart()
