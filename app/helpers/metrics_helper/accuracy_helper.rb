module MetricsHelper::AccuracyHelper

  def actual_mime_type(analysis)
    actual = analysis['actual_mime_type']
    cls = analysis['format_valid'] ? 'successful' : 'unsuccessful'
    content_tag(:td, actual, class: cls)
  end

  def filter_size_analysis(analyses)
    analyses.each do |id, analysis|
      analyses[id] = analysis.select do |information| 
        not information['expected_size'].to_s.empty?
      end
    end
  end

  def actual_resource_size(analysis)
    expected = analysis['expected_size'].to_i
    actual = analysis['actual_size'].to_i
    valid = expected == actual
    td_class = valid ? 'successful' : 'unsuccessful'

    if valid
      display = number_with_delimiter actual
    elsif actual.to_s.empty?
      display = analysis['actual_mime_type']
    else
      off = '%.2f%' % ((actual - expected).abs.fdiv(expected) * 100)
      display = "#{number_with_delimiter actual} (#{off})"
    end
    content_tag(:td, display, class: "#{td_class} percent-number")
  end

end
