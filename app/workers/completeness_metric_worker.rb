class CompletenessMetricWorker < MetricsWorker

  def perform(repository_name)
    repository = Repository.find repository_name
    schema = JSON.parse File.read 'public/ckan-schema.json'
    schema = self.class.symbolize_keys schema
    metric = Metrics::Completeness.new
    compute(repository, metric, schema)
  end

end
