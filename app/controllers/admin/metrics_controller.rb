require 'sidekiq/testing/inline' if ENV['DEBUG']

class Admin::MetricsController < ApplicationController
  include RepositoryManager
  include MetricManager

  def schedule
    worker = MetricWorker.worker_class(@metric)
    job = Job.where(repository: @repository.id, metric: @metric)
    id = worker.send(:perform_async, @repository.id, @metric)

    if job.exists?
      job.first.update_attributes!(sidekiq_id: id)
    else
      Job.create!(sidekiq_id: id, repository: @repository.id, metric: @metric)
    end

    render nothing: true
  end

  def last_updated
    snapshot = @repository.snapshots.last
    date = snapshot.send(@metric).maybe[:last_updated]

    if date.nil?
      result = { date: 'N/A', time: 'N/A' }
    else
      last_updated = DateTime.parse(date)
      result = { date: last_updated.strftime('%a %b %e %Y'),
                 time: last_updated.strftime('%T') }
    end

    render json: result
  end

end
