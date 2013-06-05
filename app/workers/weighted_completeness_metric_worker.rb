class WeightedCompletenessMetricWorker < MetricsWorker

  def perform(repository_name)
    repository = Repository.find repository_name
    schema = JSON.parse File.read 'public/ckan-schema.json'
    schema = self.class.symbolize_keys schema
    weights = 'public/ckan-weight.yml'
    metric = Metrics::WeightedCompleteness.new(schema, weights)
    compute(repository, metric)
  end

end
