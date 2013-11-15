module MetricsHelper::AccuracyHelper

  def actual_mime_type(analysis)
    actual = analysis['actual_mime_type']
    cls = analysis['format_valid'] ? 'successful' : 'unsuccessful'
    content_tag(:td, actual, class: cls)
  end

end
