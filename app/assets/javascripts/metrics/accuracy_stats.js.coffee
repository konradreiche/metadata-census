#=require d3
$ ->

  constructBarChart = () ->

    margin = {
      top:    20,
      right:  20,
      bottom: 30,
      left:   40
    }

    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    formatPercent = d3.format(".0%")
    x = d3.scale.ordinal()
      .rangeRoundBands([0, width], 0.1, 1)

    y = d3.scale.linear()
      .range([height, 0])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .tickFormat(formatPercent)

    svg = d3.select(".dashboard").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    gon.data.forEach (d) ->
      d.frequency = +d.frequency

    x.domain gon.data.map (d) -> return d.format.toUpperCase()
    y.domain([0, d3.max(gon.data, (d) -> return d.frequency)])

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Frequency")

    svg.selectAll(".bar")
      .data(gon.data)
      .enter().append("rect")
      .attr("class", "bar")
      .attr("x", (d) -> return x(d.format))
      .attr("width", x.rangeBand())
      .attr("y", (d) -> y(d.frequency))
      .attr("height", (d) -> return height - y(d.frequency))

    d3.select("button").on "click", () ->
      console.log "yep"

      x0 = x.domain(gon.data.sort(if true then (a, b) -> return (b.frequency - a.frequency)
      else (a, b) -> return (d3.ascending(a.format, b.format)))
        .map((d) -> return d.format))
        .copy()


      transition = svg.transition().duration(750)
      delay = (d, i) -> i * 50

      transition.selectAll(".bar")
        .delay(delay)
        .attr("x", (d) -> x0(d.format))

      transition.select(".x.axis")
        .call(xAxis)
        .selectAll("g")
        .delay(delay)

  if gon? and gon.data?
    constructBarChart()

