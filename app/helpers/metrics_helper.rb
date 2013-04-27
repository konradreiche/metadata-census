module MetricsHelper

  def selected?(actual, expected)
    (actual == expected) ? 'selected' : nil
  end

end
