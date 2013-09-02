module MetricsHelper

  def record_selector_entry(document)
    score = "%6.2f%" % (document[@metric][:score] * 100)
    score = score.gsub(' ', '&nbsp;')
    text = "#{score} &#8212; #{document[:record][:name]}".html_safe
    anchor = content_tag(:a, text, role: 'menuitem', tabindex: '-1', href: '#')
    content_tag(:li, anchor, role: 'presentation')
  end

end
