root = exports ? this

$ ->

  position = () ->
    this.style("left", (d) -> "#{d.x}px")
      .style("top", (d) -> "#{d.y}px")
      .style("width", (d) -> "#{Math.max(0, d.dx - 1)}px")
      .style("height", (d) -> "#{Math.max(0, d.dy - 1)}px")

  initTreemap = (selector, root) ->

    margin = { top: 25, right: 15, bottom: 0, left: 5 }
    width = 1100 - margin.left - margin.right
    height = 600 - margin.top - margin.bottom

    color = d3.scale.ordinal()
      .range(["#4F98C3", "#8CA252", "#FD8D3C"])

    treemap = d3.layout.treemap()
      .size([width, height])
      .sticky(true)
      .value (d) -> d.size

    div = d3.select(selector).append("div")
      .style("position", "relative")
      .style("width", "#{width + margin.left + margin.right}px")
      .style("height", "#{height + margin.top + margin.bottom}px")
      .style("left", "#{margin.left}px")
      .style("top", "#{margin.top}px")

    node = div.datum(root).selectAll(".node")
      .data(treemap.value(() -> 1).nodes)
      .enter().append("div")
      .attr("class", "node")
      .call(position)
      .style("background", (d) -> if d.children then color(d.name) else null )
      .text (d) -> if d.children then null else "#{d.name}"

    d3.selectAll(".treemap-switch").on "click", () ->
      $(".treemap-switch").toggleClass("active")
      value = if this.value == "structure" then () -> 1 else (d) -> d.size
      node.data(treemap.value(value).nodes)
        .transition()
        .duration(1500)
        .call(position)

  if isPath("/repositories/:repository_id/snapshots/:snapshot_id/metrics/completeness")
    initTreemap("#treemap", gon.analysis.treemap)
