class WeightedCompletenessMetricWorker < GenericMetricWorker

  def perform(repository, snapshot, metric)
    @repository ||= Repository.find(repository)
    schema = JSON.parse(File.read('data/schema/ckan.json'))
    weights = 'data/schema/ckan-weighted.yml'

    @metric = Metrics::WeightedCompleteness.instance
    @metric.configure(schema, weights)
    super
  end

end
