#=require d3
$ ->

  class MetricMeter
    
    TWO_PI: 2 * Math.PI
    
    constructor: () ->

      @arc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(35)
        .outerRadius(45)

      width = 240
      height = 125
      
      svg = d3.selectAll(".metric").insert("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

      meter = svg.append("g")
        .attr("class", "progress-meter")
        

      meter.append("path")
        .attr("class", "background")
        .attr("d", @arc.endAngle @TWO_PI)

      foreground = meter.append("path")
        .attr("class", "foreground")

    updateScore: (id, score) ->
      foreground = d3.select($("#" + id).find(".foreground")[0])
      i = d3.interpolate(0.0, score)
      foreground.transition().tween("progress", () =>
        return (t) =>
          progress = i(t)
          foreground.attr("d", @arc.endAngle(@TWO_PI * progress))).duration(1000)

  metricMeter = new MetricMeter
  metricMeter.updateScore("completeness-meter", 0.5)
