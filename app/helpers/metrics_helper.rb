module MetricsHelper

  def selected?(actual, expected)
    (actual == expected) ? 'selected' : nil
  end

  def intermediate_score(record, metric, accessors)
    accessors = accessors.to_s.to_sym
    details = (metric.to_s + "_details").to_sym
    score = record[details][accessors]
    content_tag(:a, tag('i', class: 'icon-tasks'), class: 'score-inspector',
                href: '#', data: {:toggle => 'tooltip', :placement => 'bottom',
                                  :"original-title" => "%.3f" % score}, title: '',)
  end

end
