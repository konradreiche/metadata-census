class Admin::MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  before_filter :init

  def schedule
    worker = MetricWorker.worker_class(@metric)
    id = worker.send(:perform_async, @repository.id, @metric)

    Job.create!(id: id, repository: @repository.id, metric: @metric)
    render nothing: true
  end

  private
  def init
    load_repositories(:repository_id)
    load_metrics(:metric_id)
  end


end
