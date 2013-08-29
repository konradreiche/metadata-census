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
#= require_tree .
root = exports ? this

$.fn.exists = () -> this.length > 0

# Retrieves parts of the current location path name in order to deliver the
# current context for JavaScript. This is used as a condition to decide which
# code to execute
root.getPaths = () ->
  split = window.location.pathname.split("/")
  return [split[1], split[3]]
