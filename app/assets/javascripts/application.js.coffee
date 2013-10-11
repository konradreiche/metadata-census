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

root.repositoryId = root.snapshotId = root.metricId = null

if gon? and gon.repository?
  root.repositoryId = gon.repository._id

if gon? and gon.snapshot?
  root.snapshotId = gon.snapshot._id

if gon? and gon.metric?
  root.metricId = gon.metric

# This function exists for reasons of readability
root.isPath = (path)  ->

  path = path.replace(":repository_id", repositoryId)
  path = path.replace(":snapshot_id", snapshotId)
  path = path.replace(":metric_id", metricId)

  window.location.pathname == path

class ScoreMeter

  TWO_PI: 2 * Math.PI
  ARC: d3.svg.arc()
    .startAngle(0)
    .innerRadius(50)
    .outerRadius(65)

  COLOR: d3.scale.linear()
    .domain([0.0, 0.5, 1.0])
    .range(["#FF181E", "#FFBF00", "#82CA9D"])

  WIDTH: 150
  HEIGHT: 150

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

$ ->
  # Update window location on tab clicks
  initLocationExtender = () ->
    $("nav-pills li a").on "click", (event) ->
      event.preventDefault()
      $(this).tab("show")

    $('a[data-toggle="pill"').on "shown.bs.tab", (event) ->
      window.location.hash = "#{$(this).attr("href")}".replace("#", "")

  initLocationExtender()
