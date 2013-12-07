root = exports ? this

$ ->

  ##
  #
  ##
  initWeightSlider = (sm) ->

    weightScores(sm)
    $(".weight-slider").on "change", (event) ->
      value = $(this).val()
      $(this).parents("td").find("span").text(value)
      weightScores(sm)

  ##
  #
  ##
  weightScores = (scoreMeter) ->

    weightings = {}

    scores = []
    weights = []

    $(".weight-slider").each () ->
      weight = parseInt $(this).val()
      metric = $(this).data("metric")

      weightings[metric] = weight

      if gon.snapshot[metric]?
        scores.push(gon.snapshot[metric]["average"] * weight)
        weights.push(weight)
      else
        scores.push(0.0)
        weights.push(weight)

    score = scores.reduce (t, s) -> t + s
    max = weights.reduce (t, s) -> t + s

    result = if max == 0 then 0.0 else score / max
    scoreMeter.update(result)

    $.post "/repositories/weighting", { weightings: weightings }

  # TODO: replace with Histogram class
  #
  initHistogram = () ->
    values = gon.distribution
    formatCount = d3.format(",.0f")

    margin = { top: 10, right: 30, bottom: 30, left: 30 }
    width = 835 - margin.left - margin.right
    height = 250 - margin.top - margin.bottom

    x = d3.scale.linear()
      .domain([0, 100])
      .range([0, width])

    data = d3.layout.histogram()
      .bins(x.ticks(20))(values)

    y = d3.scale.linear()
      .domain([0, d3.max(data, (d) -> d.y)])
      .range([height, 0])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")


    tip = d3.tip()
      .attr("class", "d3-tip")
      .offset([-10, 0])
      .html (d) -> "
      <div class='row tip-header'>
        <div class='col-md-12'>
          <strong>Score #{d.x}-#{d.x + 5}</strong>
        </div>
      </div>
      <div class='row'>
        <div class='col-md-12'>
          <span class=\"group-tip\">#{d.y}</span>
        </div>
      </div>
        "

    svg = d3.select("#quality-distribution").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(#{margin.left},#{margin.top})")

    svg.call(tip)

    bar = svg.selectAll(".bar")
      .data(data)
      .enter().append("g")
      .attr("class", "bar")
      .attr("transform", (d) -> "translate(#{x(d.x)},#{y(d.y)})")

    bar.append("rect")
      .attr("x", 1)
      .attr("width", x(data[0].dx) - 1)
      .attr("height", (d) -> height - y(d.y))
      .on "click", (d, i) ->
        window.location = "#{snapshotId}/metadata?distribution=#{d.x - d.x % 10}"
      .on("mouseover", tip.show)
      .on("mouseout", tip.hide)

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,#{height})")
      .on("mouseover", tip.show)
      .on("mouseout", tip.hide)
      .call(xAxis)

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id")
    sm = new ScoreMeter(".repository.score-meter", gon.score)
    initWeightSlider(sm)
    initHistogram()
