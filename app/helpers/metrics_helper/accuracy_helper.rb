module MetricsHelper::AccuracyHelper

  def actual_mime_type(analysis)
    actual = analysis['actual_mime_type']
    expected = analysis['expected_mime_types']

    cls = expected.include?(actual) ? 'successful' : 'unsuccessful'
    content_tag(:td, actual, class: cls)
  end

end
