module MetricsHelper::CompletenessHelper

  def value(value)
    blank = Metrics.blank?(value)
    value = nil if Metrics.blank?(value)

    content_tag(:td, value, class: blank ? 'incomplete' : 'complete')
  end

end

