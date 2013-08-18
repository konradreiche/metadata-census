#=require raphael-min
#=require g.raphael-min
#=require g.pie-min
$ ->

  generate_pie_chart = (values) ->
    raphael = Raphael($(".metric.link-checker.pie-chart")[0], 500, 800)
    raphael.text(250, 250, "Responses")

    information =
      legend: ['%%.%%']
      legendpos: "south"
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
        this.sector.animate({ transform: "s1 1 #{this.cx} #{this.cy}" }, 500, "bounce")
        if this.label
          this.label[0].animate({ r: 5 }, 500, "bounce")
          this.label[1].attr({ "font-weight": 400 })

    )

  if $(".metric.link-checker.pie-chart").exists
    values = (count for code, count of gon.analysis)
    generate_pie_chart(values)
