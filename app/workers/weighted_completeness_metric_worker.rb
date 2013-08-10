class WeightedCompletenessMetricWorker < GenericMetricWorker

  def perform(repository, metric)
    @repository ||= Repository.find(repository)
    schema = JSON.parse(File.read('public/ckan-schema.json'))
    schema = self.class.symbolize_keys(schema)
    weights = 'public/ckan-weight.yml'
    @metric = Metrics::WeightedCompleteness.new(schema, weights)
    super
  end

end
