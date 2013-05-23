class AccuracyMetricWorker < MetricsWorker

  def perform(repository_name)
    repository = Repository.find repository_name
    metric = Metrics::Accuracy.new
    compute(repository, metric)
  end

end
