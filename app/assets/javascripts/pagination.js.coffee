root = exports ? this

class Pagination

  constructor: (target, views) ->
    @views = $(views)
    @target = $(target)

    @numPages = @views.length
    @currentPage = 0

    @initPaginationElements()
    @initViewElements()

  initViewElements: ->
    for view in @views[1..-1]
      $(view).css("display", "none")

  initPaginationElements: ->
    html = """
    <ul class="pagination">
      <li class="disabled"><a>&laquo;</a></li>
      <li class="active"><a href="#" data-target="1">1</a></li>
    """

    for i in [2..@numPages]
      html += """<li><a href="#" data-target="#{i}">#{i}</a></li>"""

    html += """
      <li><a href="#">&raquo;</a></li>
    </ul>
    """
    pagination = @target.append(html)

    @pageAnchors = @target.find("ul li a[data-target]")
    @allAnchors = @target.find("ul li a")
    @initClickEvents()

  initClickEvents: ->
    for anchor, i in @pageAnchors
      $(anchor).on "click", @anchorClick(i)

    lastPageAnchor = @allAnchors[@allAnchors.length - 1]
    $(lastPageAnchor).on "click", @anchorClick(@numPages - 1)

  anchorClick: (page) ->
    (event) =>
      @updatePage(page)
      event.preventDefault()

  updatePage: (newPage) ->
    $(@views[newPage]).css("display", "block")
    $(@views[@currentPage]).css("display", "none")

    $(@pageAnchors[newPage]).parent().toggleClass("active")
    $(@pageAnchors[@currentPage]).parent().toggleClass("active")
    @currentPage = newPage

    firstPageAnchor = @allAnchors[0]
    lastPageAnchor = @allAnchors[@allAnchors.length - 1]

    if @currentPage > 0
      $(firstPageAnchor).parent().removeClass("disabled")
      $(firstPageAnchor).off("click")
      $(firstPageAnchor).on "click", @anchorClick(0)
      $(firstPageAnchor).prop("href", "#")

    if @currentPage < @numPages - 1
      $(lastPageAnchor).parent().removeClass("disabled")
      $(lastPageAnchor).off("click")
      $(lastPageAnchor).on "click", @anchorClick(@numPages - 1)
      $(lastPageAnchor).prop("href", "#")

    if @currentPage == @numPages - 1
      $(lastPageAnchor).parent().addClass("disabled")
      $(lastPageAnchor).off("click")
      $(lastPageAnchor).prop("href", null)

    if @currentPage == 0
      $(firstPageAnchor).parent().addClass("disabled")
      $(firstPageAnchor).off("click")
      $(firstPageAnchor).prop("href", null)

root.Pagination = Pagination
