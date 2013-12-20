root = exports ? this

PATH = "/repositories/#{repositoryId}/snapshots/#{snapshotId}/metrics/#{metricId}"

if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metrics/:metric_id")
  query = "/repositories/#{repositoryId}/snapshots/#{snapshotId}/metrics/#{metricId}/distribution"
  target = ".distribution-dashboard > .row > .col-md-12 > .spinner"
  loadData query, null, target, (distribution) ->
    new Histogram("#quality-distribution", distribution, [0, 100])
    
$ ->

  registerSelectionEntry = () ->
    $("#search-by-score-0").on "show.bs.modal", (e) ->
      range = $(e.relatedTarget).data("range").split("-")
      url = PATH + "/metadata"
      range = { from: range[0], to: range[1] }

      loadData url, range, "#search-by-score-result > .spinner", (result) ->

        table = """
                <table class="table table-striped">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Score</th>
                     </tr>
                   </thead>
                   <tbody>
                """

        for document in result
          table += """
                       <tr>
                         <td>#{document.record.name}</td>
                         <td>#{(document.score * 100).toFixed(2)}</td>
                       </tr>
                   """

        table += """
                   </tbody>
                 </table>
                 """

        $("#search-by-score-result").append(table)
        

  registerSelectionEntry()

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
  initBarChart = (scores, selector) ->

    return unless $(selector).exists()

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

    svg = d3.select(selector).append("svg")
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
    initRecordSearch(i) for i in [0..1]
