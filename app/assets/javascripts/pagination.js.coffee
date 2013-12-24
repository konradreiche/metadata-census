root = exports ? this

class Pagination

  constructor: (@views) ->
    @page = 1
    for view in $(@views)[1..-1]
      $(view).css("display", "none")

  setPage: (page) ->

  nextPage: ->

  previousPage: ->

root.Pagination = Pagination
