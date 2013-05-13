#=require d3
$ ->

  class MetricMeter
    
    TWO_PI: 2 * Math.PI
    
    constructor: (metric) ->

      @arc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(35)
        .outerRadius(45)

      width = 240
      height = 125

      selector = "##{metric}-meter"
      svg = d3.select(selector).insert("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

      meter = svg.append("g")
        .attr("class", "progress-meter")

      meter.append("path")
        .attr("class", "background")
        .attr("d", @arc.endAngle @TWO_PI)

      @foreground = meter.append("path")
        .attr("class", "foreground")

      @text = meter.append("text")
        .attr("text-anchor", "middle")
        .attr("dy", ".35em")
        .text("?")

      $(selector).bind "click", (event) =>
        repository = $("select[name=repository]").val()
        $.post("metrics/compute", {
          "repository": repository,
          "metric": metric
        }, (data, status) =>
          @updateScore(data)
        )

    updateScore: (score) ->
      i = d3.interpolate(0.0, score)
      @foreground.transition().tween("progress", () =>
        return (t) =>
          progress = i(t)
          @foreground.attr("d", @arc.endAngle(@TWO_PI * progress))
      ).duration(1000).each("end", () =>
        formatPercent = d3.format(".0%")
        @text.text(formatPercent score).transition().delay(1000)
      )

  $(".metric").each () ->
    metric = @id.split("-meter")[0]
    new MetricMeter metric
