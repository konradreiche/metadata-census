root = exports ? this

$ ->

  ##
  # Sets up the pie chart for the statistics tab
  #
  initPieChart = (analysis) ->

    data = []
    for key, value of analysis
      data.push({ key: key, value: value })

    width = 350
    height = 250
    radius = Math.min(width, height) / 2

    color = d3.scale.ordinal().range(["#98abc5", "#8a89a6", "#7b6888",
      "#6b486b", "#a05d56", "#d0743c", "#ff8c00"])

    arc = d3.svg.arc()
      .outerRadius(radius - 10)
      .innerRadius(0)

    pie = d3.layout.pie()
      .sort(null)
      .value((d) -> return d.value)

    svg = d3.select("#pie-chart").append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

    g = svg.selectAll(".arc")
      .data(pie(data))
      .enter().append("g")
      .attr("class", "arc")

    g.append("path")
      .attr("d", arc)
      .style("fill", (d) -> return color(d.data.key))

    # create legend
    legend = d3.select("#pie-chart").append("svg")
      .attr("class", "legend")
      .attr("width", 100)
      .attr("height", 225)
      .selectAll("g")
      .data(color.domain().slice().reverse())
      .enter().append("g")
      .attr("transform", (d, i) -> "translate(0,#{i * 20})")

    legend.append("rect")
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color)

    legend.append("text")
      .attr("x", 24)
      .attr("y", 9)
      .attr("dy", ".35em")
      .text((d) -> d)
    

  recordSelectionLink = (current, next) ->
    documents = (root.id(document) for document in gon.documents)
    documents[documents.indexOf(current)] = next
    parameter = ({ name: "documents[]", value: id } for id in documents)
    query = decodeURIComponent($.param(parameter))
    "?#{query}"

  normalize = (score) ->
    ajax =
      dataType: "json"
      url: "/repositories/#{gon.repository.name}/metadata/normalize"
      async: false
      data: { metric: gon.metric, score: score }

    return parseFloat($.ajax(ajax).responseText)

  ###
  Draws the bar chart to display the score distribution grouped by groups.
  ###
  initBarChart = (scores) ->

    data = []
    for key, value of scores
      data.push({ group: key, score: value })

    margin =
      top: 0
      right: 0
      bottom: 30
      left: 40

    width = 1000 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    xAxisOffset = 25

    x = d3.scale.linear()
      .range([0, width])

    y = d3.scale.ordinal()
      .rangeBands([0, height], .2)

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")

    yAxis.tickFormat("")

    tip = d3.tip()
      .attr("class", "d3-tip")
      .offset([-10, 0])
      .html (d) ->
        "<strong>Group: </strong> <span class=\"group-tip\">#{d.group}</span>"

    svg = d3.select("#bar-chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(#{margin.left},#{margin.top})")

    svg.call(tip)

    x.domain([0, d3.max(data, (d) -> d.score )])
    y.domain(data.map (d) -> d.group)

    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(10,0)")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", -xAxisOffset)
      .attr("dy", ".5em")
      .style("text-anchor", "end")
      .text("Groups")

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(#{xAxisOffset},#{height})")
      .call(xAxis)

    svg.selectAll(".bar")
      .data(data)
      .enter().append("rect")
      .attr("class", "bar")
      .attr("x", xAxisOffset)
      .attr("y", (d) -> y(d.group))
      .attr("width", (d) -> x(d.score))
      .attr("height", (d) -> y.rangeBand())
      .on("mouseover", tip.show)
      .on("mouseout", tip.hide)

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
      url = "/repositories/#{gon.repository.name}/metadata/search"

      list.clear()
      $.getJSON url, data, (result) =>

        for document in result
          name = document.record.name
          score = (document[gon.metric].score).toFixed(2)
          score = normalize(score).toFixed(2)
          list.add({ name: name, score: "#{score * 100}%", id: id(document) })

        # add row link feature
        $(".list > tr").addClass("rowlink")
        $(".list > tr > td").addClass("nolink")
        current = $("#record-search-results-#{i}").data("document")

        for item in list.items
          text = $(item.elm).children("td:first-child").contents()
          attributes = { href: recordSelectionLink(current, item.values().id) }
          text.wrap($("<a>", attributes))
    , 500)

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metrics/:metric_id")
    sm = new ScoreMeter(".metric.score-meter", gon.score)
    hg = new Histogram("#quality-distribution", gon.distribution)

    initRecordSearch(i) for i in [0..1]
    initPieChart(gon.analysis.details)
    initBarChart(gon.analysis.scores)
