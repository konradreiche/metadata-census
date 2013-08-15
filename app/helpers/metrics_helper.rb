module MetricsHelper

  def selected?(actual, expected)
    (actual == expected) ? 'selected' : nil
  end

  def intermediate_score(record, metric, accessors)
    accessors = accessors.to_s.to_sym

    if record[metric][:report].nil? or record[metric][:report][accessors].nil?
      return
    end

    score = record[metric][:report][accessors]
    content_tag(:a, content_tag('i', '', class: 'glyphicon-tasks'), class: 'score-inspector',
                href: '#', data: {:toggle => 'tooltip', :placement => 'bottom',
                                  :"original-title" => "%.3f" % score}, title: '')
  end

  def record_link(record, kind)
    best = params[:best]
    best = record[:id] if kind == :best
    worst = params[:worst]
    worst = record[:id] if kind == :worst
    url = "richness-of-information?repository=#{@repository.name}"
    url += "&best=#{best}" unless best.nil?
    url += "&worst=#{worst}" unless worst.nil?
    url
  end

  def record_selector(metric, kind)
    records = @repository.best_records(metric) if kind == :best
    records = @repository.worst_records(metric) if kind == :worst

    link_label = (kind == :best) ? "Best Record" : "Worst Record"
    menu = content_tag(:a, link_label, class: 'dropdown-toggle',
                       id: 'dLabel', role: 'button', href: '#',
                       data: {:toggle => 'dropdown', 'target' => '#'})

    caret = content_tag(:strong, '', class: 'caret')
    items = content_tag(:ul, class: 'dropdown-menu') do
      records.each do |record|
        score = "%.4f" % record[metric][:score]
        url = record_link(record, kind)
        anchor = content_tag(:a, score, role: 'menuitem', href: url)
        concat(content_tag(:li, anchor, role: 'presentation'))
      end
    end

    content_tag(:div, (menu + caret + items).html_safe, class: 'dropdown')
  end

  def print_tags(metadata, metric, field)
    result = ""
    record = metadata[:record]
    value = record.has_key?(field) ? record[field] : ""
    value.each_with_index do |tag, i|
      result += tag + ' ' + intermediate_score(metadata, metric, [field, i]) + ' '
    end
    result.html_safe
  end

end
