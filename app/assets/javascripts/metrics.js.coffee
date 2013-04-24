#=require d3
$ ->
  width = 960
  height = 500
  twoPi = 2 * Math.PI

  arc = d3.svg.arc()
    .startAngle(0)
    .innerRadius(180)
    .outerRadius(240)

  svg = d3.select("#metric-bar").append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  meter = svg.append("g")
    .attr("class", "progress-meter")
    
  meter.append("path")
    .attr("class", "background")
    .attr("d", arc.endAngle(twoPi))

  foreground = meter.append("path")
    .attr("class", "foreground")

  i = d3.interpolate(0.0, 0.5)
  foreground.transition().tween("progress", () ->
    return (t) ->
      progress = i(t)
      foreground.attr("d", arc.endAngle(twoPi * progress))).duration(1000)
