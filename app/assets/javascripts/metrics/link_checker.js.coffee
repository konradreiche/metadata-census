#=require raphael-min
#=require g.raphael-min
#=require g.pie-min
$ ->

  generate_pie_chart = () ->
    raphael = Raphael($(".metric.link-checker.pie-chart")[0], 500, 500)
    information =
      legend: []
      legendpos: "west"
      href: []

    pie = raphael.piechart(250, 250, 200, [55, 20, 13, 32, 5, 1, 2, 10], information)

  if $(".metric.link-checker.pie-chart").exists
    generate_pie_chart()
