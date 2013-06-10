#=require d3
$ ->
  
  if gon? and gon.accessibility_by_portals?
    data = { children: [] }
    for portal, score of gon.accessibility_by_portals
      data.children.push { name: portal, value: score }

    width = 960
    height = 750

    pack = d3.layout.pack()
      .sort(d3.descending)
      .size([width, height])

    svg = d3.select("#canvas").append("svg")
      .attr("width", width)
      .attr("height", height)

    node = svg.data([data]).selectAll(".node")
      .data(pack.nodes)

    g = node.enter().append("g")
    g.append("circle")
      .attr("class", "node")
      .attr("transform", (d) -> return "translate(" + d.x + "," + d.y + ")")
      .attr("r", (d) -> return d.r)
    g.append("text")
      .style("text-anchor", "middle")
      .text((d) -> d3.round(d.value, 2))
      .attr("transform", (d) -> "translate(" + d.x + "," + d.y + ")")
