module MetricsHelper

  def selected?(actual, expected)
    p actual
    p expected
    p actual == expected
    (actual == expected) ? 'selected' : nil
  end

end
