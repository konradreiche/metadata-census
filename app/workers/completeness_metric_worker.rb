class CompletenessMetricWorker < MetricWorker

  def perform(repository, metric)
    @repository ||= Repository.find(repository)
    schema = JSON.parse(File.read('public/ckan-schema.json'))
    schema = self.class.symbolize_keys(schema)
    @metric = Metrics::Completeness.new(schema)
    super
  end

end
