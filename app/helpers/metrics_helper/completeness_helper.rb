module MetricsHelper::CompletenessHelper

  def value(value)
    blank = Metrics.blank?(value)
    value = nil if Metrics.blank?(value)
    cls = blank ? 'incomplete' : 'complete'

    content_tag(:td, value, class: cls , title: value)
  end

end

