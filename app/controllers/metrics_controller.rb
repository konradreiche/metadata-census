require 'sidekiq/testing/inline' if ENV['DEBUG']

class MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric 

  @@jobs = Hash.new { |hash, key| hash[key] = Hash.new }
  
  def overview
    begin
      preprocess
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
  end

  def show
    load_repositories(:repository)
    load_metrics(:metric)
  end

  def status
    status = Hash.new { |hash, key| hash[key] = Hash.new }
    @@jobs.each do |repository, metrics|
      metrics.each  do |metric, id|
        status[repository][metric] = Sidekiq::Status::get_all(id)
        percent = Sidekiq::Status::pct_complete(id)
        status[repository][metric]['percent'] = percent.finite? ? percent : 0.0
      end
    end
    render :json => status
  end

  def preprocess
    @repositories = Repository.all
    if params[:repository].nil?
      @selected = @repositories.first if @selected.nil?
    else
      @selected = Repository.find params[:repository]
    end
    gon.repository = @selected.to_hash
  end

  def accuracy_stats
    preprocess
    stats = Hash.new(0)

    size = 0.0
    metadata = @selected.metadata
    metadata.each do |document|
      record = document[:record]
      record[:resources].each do |resource|
        format = resource[:format]
        format = resource[:mimetype] unless resource[:mimetype].nil?
        next if format.nil?
        size += 1
        stats[format.downcase] += 1
      end
    end
    stats = stats.inject([]) do |result, item|
      result << { "format" => item[0],
                  "frequency" => item[1] / size }
    end
    gon.data = stats
  end

  def compute
    repositories = create_repository_list(params[:repository])
    metrics = create_metric_list(params[:metric])

    repositories.each do |repository|
      metrics.each do |metric|
        worker = MetricWorker.worker_class(metric)
        id = worker.send(:perform_async, repository.name, metric)
        @@jobs[repository.name][metric] = id
      end
    end
    render :nothing => true
  end

  def create_repository_list(parameter)
    if parameter == '*'
      Repository.all
    else
      [Repository.find(parameter)]
    end
  end

  def create_metric_list(parameter)
    if parameter == '*'
      Metrics::IDENTIFIERS
    else
      [parameter.to_sym]
    end
  end

end
