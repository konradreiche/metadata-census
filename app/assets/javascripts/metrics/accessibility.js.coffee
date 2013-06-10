#=require d3
$ ->
  
  if gon? and gon.accessibility_by_portals?
    data = []
    for portal, score of gon.accessibility_by_portals
      data.push { name: portal, value: score }

    m = [30, 10, 10, 100]
    w = 800 - m[1] - m[3]
    h = 930 - m[0] - m[2]

    format = d3.format(",.2f")

    x = d3.scale.linear().range([0, w])
    y = d3.scale.ordinal().rangeRoundBands([0, w], .1)

    xAxis = d3.svg.axis().scale(x).orient("top").tickSize(-h)
    yAxis = d3.svg.axis().scale(y).orient("left").tickSize(0)

    svg = d3.select("#canvas").append("svg")
      .attr("width", w + m[1] + m[3])
      .attr("height", h + m[0] + m[2])
      .append("g")
      .attr("transform", "translate(" + m[3] + "," + m[0] + ")")

    data.sort((a, b) -> b.value - a.value)

    x.domain([0, d3.max(data, (d) -> d.value)])
    y.domain(data.map((d) -> d.name))

    bar = svg.selectAll("g.bar")
      .data(data)
      .enter().append("g")
      .attr("class", "bar")
      .attr("transform", (d) -> "translate(0," + y(d.name) + ")")

    bar.append("rect")
      .attr("width", (d) -> x(d.value))
      .attr("height", y.rangeBand())

    bar.append("text")
      .attr("class", "value")
      .attr("x", (d) -> x(d.value))
      .attr("y", y.rangeBand() / 2)
      .attr("dx", -3)
      .attr("dy", ".35em")
      .attr("text-anchor", "end")
      .text((d) -> format(d.value))
 
    svg.append("g")
      .attr("class", "x axis")
      .call(xAxis)
 
    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
