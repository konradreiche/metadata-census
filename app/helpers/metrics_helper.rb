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

  def print_tags(record, metric, field)
    result = ""
    value = record.has_key?(field) ? record[field] : ""
    value.each_with_index do |tag, i|
      result += tag + ' ' + intermediate_score(record, metric, [field, i]) + ' '
    end
    result.html_safe
  end

end
