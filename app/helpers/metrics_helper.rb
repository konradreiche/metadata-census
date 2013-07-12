module MetricsHelper

  def selected?(actual, expected)
    (actual == expected) ? 'selected' : nil
  end

  def intermediate_score(record, metric, accessors)
    accessors = accessors.to_s.to_sym
    details = (metric.to_s + "_details").to_sym

    if record[details].nil? or record[details][accessors].nil?
      return
    end

    score = record[details][accessors]
    content_tag(:a, content_tag('i', '', class: 'icon-tasks'), class: 'score-inspector',
                href: '#', data: {:toggle => 'tooltip', :placement => 'bottom',
                                  :"original-title" => "%.3f" % score}, title: '')
  end

  def record_link(record)
    link = 'richness-of-information'
    link = link + '?repository=' + @repository.name
    link = link + '&best=' + record[:id]
    link
  end

  def record_dropdown_selector(records, metric, display_name)

    menu = content_tag(:a, display_name, class: 'dropdown-toggle',
                       id: 'dLabel', role: 'button', href: '#',
                       data: {:toggle => 'dropdown', 'target' => '#'})

    caret = content_tag(:strong, '', class: 'caret')
    items = content_tag(:ul, class: 'dropdown-menu') do
      records.each do |record|
        score = "%.4f" % record[metric]
        link = content_tag(:a, score, role: 'menuitem', href: record_link(record))
        concat(content_tag(:li, link, role: 'presentation'))
      end
    end

    content_tag(:div, (menu + caret + items).html_safe, class: 'dropdown')
  end

  def print_tags(record, metric, field)
    result = ""
    value = record.has_key?(field) ? record[field] : ""
    value.each_with_index do |tag, i|
      result += tag + ' ' + intermediate_score(record, metric, [field, i]) + ' '
    end
    result.html_safe
  end

end
