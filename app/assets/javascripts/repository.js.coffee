metricMeter = (selector, score) ->

  twoPi = 2 * Math.PI

  arc = d3.svg.arc()
    .startAngle(0)
    .innerRadius(35)
    .outerRadius(45)

  width = height = 120
  svg = d3.select(selector).insert("svg")
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

  text = meter.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", ".35em")

  i = d3.interpolate(0.0, score)
  foreground.transition().tween("progress", () =>
    return (t) =>
      progress = i(t)
      foreground.attr("d", arc.endAngle(twoPi * progress))
  ).duration(1000).each("end", () =>
    formatPercent = d3.format(".0%")
    text.text(formatPercent score).transition().delay(1000)
  )

$ ->
  metricMeter(".repository.score.meter", gon.score)
