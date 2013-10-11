require 'sidekiq/testing/inline' if ENV['DEBUG']

class Admin::MetricsController < ApplicationController
  include RepositoryManager
  include MetricManager

  def schedule
    worker = MetricWorker.worker_class(@metric)
    snapshot_date = @snapshot.date.to_s
 
    job = Job.where(repository: @repository.id, snapshot: snapshot_date, metric: @metric)
    id = worker.send(:perform_async, @repository.id, @snapshot.date, @metric)

    if job.exists?
      job.first.update_attributes!(sidekiq_id: id)
    else
      Job.create!(sidekiq_id: id, repository: @repository.id, snapshot: snapshot_date, metric: @metric)
    end

    render nothing: true
  end

  def last_updated
    date = @snapshot.send(@metric).maybe['last_updated']

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
