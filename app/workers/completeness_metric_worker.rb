class CompletenessMetricWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(repository_name)
    repository = Repository.find repository_name
    schema = JSON.parse File.read 'public/ckan/schema.json'
    schema = symbolize_keys schema
    metric = Metrics::Completeness.new
    compute(repository, metric, *args)
  end

end
