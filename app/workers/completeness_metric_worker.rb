class CompletenessMetricWorker < GenericMetricWorker

  def perform(repository, metric)
    @repository ||= Repository.find(repository)
    schema = JSON.parse(File.read('public/ckan-schema.json'))
    @metric = Metrics::Completeness.new(schema)
    super
  end

end
