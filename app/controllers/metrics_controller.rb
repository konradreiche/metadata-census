require 'sidekiq/testing/inline' if ENV['DEBUG']

class MetricsController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric 
  include Report::Metric

  helper_method :metric_score, :record

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
    load_records
    report(@metric, @repository)
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

  def load_records
    2.times do |i|
      variable = "record#{i + 1}"
      instance_variable = "@#{variable}"
      parameter = variable.to_sym

      record = default_record(i + 1)
      instance_variable_set(instance_variable, default_record(i + 1))
      unless params[parameter].nil?
        record = @repository.get_record(params[parameter])
        instance_variable_set(instance_variable, record)
      end
      gon.send("#{variable}=", record)
    end
  end

  def default_record(i)
    case i
    when 1
      @repository.best_record(@metric)
    when 2
      @repository.worst_record(@metric)
    end
  end

  def record(i)
    instance_variable_get("@record#{i + 1}")
  end

end
