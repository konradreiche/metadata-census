#=require d3
$ ->

  check_result = (result) ->
      repeat = false
      for metric, status of result
        if not repeat
          repeat = repeat or status.percent != 100
        $("##{metric} .bar").css('width', status.percent + '%')
      if repeat
        setTimeout(check_progress, 500)

  check_progress = () ->
    $.getJSON('/metrics/status', check_result)

  metricMeter = {}

  class MetricMeter
    
    TWO_PI: 2 * Math.PI
    
    constructor: (metric) ->

      @arc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(35)
        .outerRadius(45)

      width = 240
      height = 125

      selector = "##{metric}"
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
          check_progress()
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

  $(".metric-meter").each () ->
    metric = @id
    metricMeter[metric] = new MetricMeter metric

  $(".score").bind "click", (event) =>
    metric = $(event.target).parent()[0].id
    repository = $("select[name=repository]").val()
    $.post("metrics/compute", {
      "repository": repository,
      "metric": metric
    }, (data, status) =>
      $("#" + metric + " " + ".score").text(parseFloat(data).toFixed(2))
      check_progress()
    )

  load_scores = (repository, metricMeter) ->

    for metric in ['accessibility', 'richness-of-information']
      attribute = metric.replace(/-/g, '_')
      if gon.repository[attribute]?
        score = gon.repository[attribute].average
        $("##{metric} .score").text(parseFloat(score).toFixed(2))

    for metric in ['completeness', 'weighted-completeness',
      'accuracy']

      attribute = metric.replace(/-/g, '_')
      if gon.repository[attribute]?
        score = gon.repository[attribute].average
        metricMeter[metric].updateScore(score)
      
  if gon? and gon.repository?
    load_scores(gon.repository, metricMeter)
    check_progress()
