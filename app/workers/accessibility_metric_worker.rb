class AccessibilityMetricWorker < GenericMetricWorker

  def perform(repository, metric)
    @metric = Metrics::Accessibility.new('en_us')
    super
  end

end
