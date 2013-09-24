# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require bootstrap
#= require jquery_ujs
#= require list.min.js
#= require underscore.js
#= require d3
#= require d3.tip.js
#= require_tree .
root = exports ? this

$.fn.exists = () -> this.length > 0
RegExp.escape = (string) -> string.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

# Function to retrieve identifier from a MongoDB document
root.id = (document) -> document["_id"]["$oid"]

# Regular expression for repository identifier
root.regExps = { repository_id: "[0-z\.]+" }

# Retrieves parts of the current location path name in order to deliver the
# current context for JavaScript. This is used as a condition to decide which
# code to execute
root.getPath = (index) ->
  split = window.location.pathname.split("/")
  paths = [split[1], split[3]]
  return paths[index - 1]

# This function exists for reasons of readability
root.isPath = (path, id)  ->
  paths = path.split(":repository_id")
  paths = paths.map (path) -> RegExp.escape(path)
  regExp = root.regExps.repository_id
  new RegExp(paths.join(regExp)).test(window.location.pathname)

class ScoreMeter

  TWO_PI: 2 * Math.PI
  ARC: d3.svg.arc()
    .startAngle(0)
    .innerRadius(35)
    .outerRadius(45)

  COLOR: d3.scale.linear()
    .domain([0.0, 0.5, 1.0])
    .range(["#FF181E", "#FFBF00", "#82CA9D"])

  WIDTH: 120
  HEIGHT: 120

  constructor: (selector, score) ->

    @score = 0.0
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

    @foreground = meter.append("path")
      .attr("class", "foreground")

    @text = meter.append("text")
      .attr("text-anchor", "middle")
      .attr("dy", ".35em")

    @update(score)

  update: (score) ->
    i = d3.interpolate(@score, score)
    @score = score
    @foreground.transition().tween("progress", () =>
      return (t) =>
        progress = i(t)
        @foreground.attr("d", @ARC.endAngle(@TWO_PI * progress))
        @foreground.attr("fill", @COLOR(progress))
    ).duration(1000).each("end", () =>
      formatPercent = d3.format(".0%")
      @text.text(formatPercent score).transition().delay(1000)
    )

root.ScoreMeter = ScoreMeter

# Activate repository breadcrumb dropdown if available
$('.dropdown-toggle').dropdown()

