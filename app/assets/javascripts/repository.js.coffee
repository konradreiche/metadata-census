root = exports ? this

class ScoreMeter

  TWO_PI: 2 * Math.PI
  ARC: d3.svg.arc()
    .startAngle(0)
    .innerRadius(35)
    .outerRadius(45)

  COLOR: d3.scale.linear()
    .domain([0.0, 0.5, 1.0])
    .range(["#CE1836", "#EDB92E", "#A3A948"])

  WIDTH: 120
  HEIGHT: 120

  constructor: (selector, score) ->

    svg = d3.select(selector).insert("svg")
      .attr("width", @WIDTH)
      .attr("height", @HEIGHT)
      .append("g")
      .attr("transform", "translate(" + @WIDTH / 2 + "," + @HEIGHT / 2 + ")")

    meter = svg.append("g")
      .attr("class", "progress-meter")

    meter.append("path")
      .attr("class", "background")
      .attr("d", @ARC.endAngle(@TWO_PI))

    foreground = meter.append("path")
      .attr("class", "foreground")

    text = meter.append("text")
      .attr("text-anchor", "middle")
      .attr("dy", ".35em")

    i = d3.interpolate(0.0, score)
    foreground.transition().tween("progress", () =>
      return (t) =>
        progress = i(t)
        foreground.attr("d", @ARC.endAngle(@TWO_PI * progress))
        foreground.attr("fill", @COLOR(progress))
    ).duration(1000).each("end", () =>
      formatPercent = d3.format(".0%")
      text.text(formatPercent score).transition().delay(1000)
    )

# Update the metriiic scores according to the weighting
updateScores = () ->
  $("#weighting-modal").on "hidden.bs.modal", () =>
    weighting = {}
    for metric in gon.metrics
      weight = $("input[id^=#{metric}]").val()
      if not not weight
        weighting[metric] = weight
    $.getJSON "#{window.location.pathname}/score", weighting, (data) =>
      console.log data
$ ->

  if getPaths()[0] == 'repository'
    new ScoreMeter(".repository.score.meter", gon.score)
    new ScoreMeter(".metric.score.meter", gon.score)
    updateScores()
