class AccessibilityMetricWorker < MetricsWorker

  def perform(repository_name)
    repository = Repository.find repository_name
    metric = Metrics::Accessibility.new 'en_us'
    compute(repository, metric)
  end

end
