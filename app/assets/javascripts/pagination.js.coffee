root = exports ? this

class Pagination

  constructor: (selector) ->

    @pageAnchors = $("#{selector} > li > a[data-target]")
    for pageAnchor in @pageAnchors[1..-1]
      view = $(pageAnchor).data("target")
      $("##{view}").css("display", "none")
      $(pageAnchor).on "click", @pageAnchorClick(view, pageAnchor)

    @currentPageAnchor = @pageAnchors[0]
    @currentPage = $(@currentPageAnchor).data("target")

  addElements: (selector, numPages) ->
    html = """
    <ul class="pagination">
      <li class="disabled"><a href="#">&laquo;</a></li>
      <li><a href="#">&raquo;</a></li>
      <li class="active"><a href="#">1</a></li>
    """

    for i in [2..numPages]
      html += """<li class="active"><a href="#">#{i}</a></li>"""

    html += """
    </ul>
    """
    pagination = $(selector).append(html)

  pageAnchorClick: (view, pageAnchor) ->
    (event) => @setPage(view, pageAnchor)

  setPage: (view, pageAnchor) ->
    $("##{view}").css("display", "block")
    $("##{@currentPage}").css("display", "none")

    @currentPage = view
    $(@currentPageAnchor).parent().toggleClass("active")

    @currentPageAnchor = pageAnchor
    $(@currentPageAnchor).parent().toggleClass("active")

  nextPage: ->

  previousPage: ->

root.Pagination = Pagination
