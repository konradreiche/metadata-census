module MetricsHelper

  ##
  # Constructs an entry for the record selector based on a given document.
  #
  # The +current+ document is used to find the document to replace for the new
  # link. The +new+ document is used for the menu item text and the link.
  #
  def record_selector_entry(current, new)
    normalized = Metrics.normalize(@metric, new.send(@metric)[:score])
    score = "%6.2f%" % (normalized * 100)
    score = score.gsub(' ', '&nbsp;')

    text = "#{score} &#8212; #{new.record[:name]}".html_safe
    href = record_selector_entry_link(current, new)

    anchor = content_tag(:a, text, role: 'menuitem', tabindex: '-1', href: href)
    content_tag(:li, anchor, role: 'presentation')
  end

  ##
  # Constructs the link for an entry of the record selector
  #
  def record_selector_entry_link(current, new)
    documents = @documents.map { |document| document.id }
    documents[documents.index(current.id)] = new.id

    query = documents.map do |document|
      URI.unescape(document.to_query(:"documents[]"))
    end * '&'
    "?#{query}"
  end

end
