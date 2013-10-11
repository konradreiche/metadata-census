class WeightedCompletenessMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    @repository ||= Repository.find(repository)
    schema = JSON.parse(File.read('public/ckan-schema.json'))

    weights = 'public/ckan-weight.yml'
    @metric = Metrics::WeightedCompleteness.new(schema, weights)
    super
  end

end
