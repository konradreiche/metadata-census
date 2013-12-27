root = exports ? this

class Pagination

  constructor: (target, views) ->
    @views = $(views)
    @target = $(target)

    @numPages = @views.length
    @page = 0

    @initPaginationElements()
    @initViewElements()

  initViewElements: ->
    for view in @views[1..-1]
      $(view).css("display", "none")

  initPaginationElements: ->
    html = """
    <ul class="pagination">
      <li class="disabled"><a href="#">&laquo;</a></li>
      <li class="active"><a href="#" data-target="1">1</a></li>
    """

    for i in [2..@numPages]
      html += """<li><a href="#" data-target="#{i}">#{i}</a></li>"""

    html += """
      <li><a href="#">&raquo;</a></li>
    </ul>
    """
    pagination = @target.append(html)
    @anchors = @target.find("ul li a[data-target]")
    @initClickEvents()

  initClickEvents: ->
    for anchor, i in @anchors
      $(anchor).on "click", @anchorClick(@views[i], anchor)

  anchorClick: (view, anchor) ->
    (event) =>
      @updatePage(view, anchor)
      event.preventDefault()

  updatePage: (view, anchor) ->
    $(view).css("display", "block")
    $(@views[@page]).css("display", "none")

    $(@anchors[@page]).parent().toggleClass("active")
    @page = @views.index(view)
    $(@anchors[@page]).parent().toggleClass("active")

  nextPage: ->

  previousPage: ->

root.Pagination = Pagination
