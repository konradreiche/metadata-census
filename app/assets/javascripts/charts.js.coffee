root = exports ? this

class Histogram

  constructor: (selector, values, domain) ->

    formatCount = d3.format(",.0f")

    margin = { top: 10, right: 30, bottom: 30, left: 50 }
    width = 835 - margin.left - margin.right
    height = 250 - margin.top - margin.bottom

    xTicks = 20

    x = d3.scale.linear()
      .domain(domain)
      .range([0, width])

    data = d3.layout.histogram()
      .bins(x.ticks(xTicks))(values)

    y = d3.scale.linear()
      .domain([0, d3.max(data, (d) -> d.y)])
      .range([height, 0])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .ticks(5)

    yAxis.tickSize(- width)
    yAxis.tickPadding(15)

    svg = d3.select(selector).append("svg")
      .attr("class", "histogram")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(#{margin.left},#{margin.top})")

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,#{height})")
      .call(xAxis)

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")

    tip = @tooltip(domain[1], xTicks)
    svg.call(tip)

    bar = svg.selectAll(".histogram-bar")
      .data(data)
      .enter().append("g")
      .attr("class", "histogram-bar")
      .attr("transform", (d) -> "translate(#{x(d.x)},#{y(d.y)})")

    bar.append("rect")
      .attr("x", 1)
      .attr("width", x(data[0].dx))
      .attr("height", (d) -> height - y(d.y))
      .on "click", (d, i) ->
        window.location = "#{snapshotId}/metadata?distribution=#{d.x - d.x % 10}"
      .on("mouseover", tip.show)
      .on("mouseout", tip.hide)

  tooltip: (max, ticks) ->
    steps = max / ticks
    html = (d) ->
      "<div class='row tip-header'>
         <div class='col-md-12'>
           <strong>Score #{d.x}-#{d.x + steps}</strong>
         </div>
       </div>
       <div class='row'>
         <div class='col-md-12'>
           <span>#{d.y}</span>
         </div>
       </div>"

    d3.tip()
      .attr("class", "d3-tip animate")
      .offset([-10, 0])
      .html (d) -> html(d)


root.Histogram = Histogram
