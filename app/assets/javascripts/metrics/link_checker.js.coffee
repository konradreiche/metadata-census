#=require raphael-min
#=require g.raphael-min
#=require g.pie-min
$ ->

  activatePieChart = () ->
    divPieChart = $(".metric.link-checker.pie-chart")
    if divPieChart.is(":empty") and not divPieChart.is(":hidden")
      values = (count for code, count of gon.analysis)
      legend = ("## - #{renderCode(code)}" for code, count of gon.analysis)
      generate_pie_chart(values, legend)

  # Filter for the result table
  tableFilter = () ->
    $("#link-checker-filter").on "input", (event) ->
       rows = $(".link-checker-table > tbody > tr")
       rows.hide()
       rows.filter(":contains(#{$(this).val()})").show()
  tableFilter()

  renderCode = (code) ->
    if isFinite(code) and not isNaN(code)
      "HTTP #{code}"
    else
      code

  if $(".metric.link-checker.pie-chart").exists
    $(".metrics.nav >> a.statistics").on "click", (event) =>

  generate_pie_chart = (values, legend) ->
    raphael = Raphael($(".metric.link-checker.pie-chart")[0], 1000, 500)
    raphael.text(250, 250, "Responses")

    information =
      legend: legend
      legendpos: "east"
      minPercent: 0.001
      href: []

    pie = raphael.piechart(250, 250, 200, values, information)
    pie.hover(
      () ->
        this.sector.stop()
        this.sector.scale(1.1, 1.1, this.cx, this.cy)

        if this.label
          this.label[0].stop()
          this.label[0].attr({ r: 7.5 })
          this.label[1].attr({ "font-weight": 800 })

      , () ->
        this.sector.stop()
        this.sector.animate({ transform: "s1 1 #{this.cx} #{this.cy}" }, 500, "bounce")
        if this.label
          this.label[0].animate({ r: 5 }, 500, "bounce")
          this.label[1].attr({ "font-weight": 400 })

    )
