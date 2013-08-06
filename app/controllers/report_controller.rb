class ReportController < ApplicationController
  include Concerns::Repository
  helper_method :metric_score, :record

  def repository
    load_repositories(:show)
    @score = average_score(@repository)
  end

  def metric
    load_repositories(:repository)

    if params[:show].nil?
      @metric = :completeness
    else
      @metric = params[:show].underscore.to_sym
    end
    gon.metric = @metric

    @record1 = @repository.best_record(@metric)
    @record2 = @repository.worst_record(@metric)

    2.times do |i|
      parameter = "record#{i + 1}".to_sym
      unless params[parameter].nil?
        record = @repository.get_record(params[parameter])
        instance_variable_set("@record#{i + 1}", record)
      end
    end
  end

  def metric_score(metric)
    value = @repository.send(metric)
    unless value.nil?
      value = value[:average]
      value = Metrics::normalize(metric, [value]).first
      '%.2f' % (value  * 100)
    else
      ''
    end
  end

  def average_score(repository)
    metrics = Metrics::IDENTIFIERS
    sum = metrics.inject(0.0) do |sum, metric|
      score = repository.send(metric)
      unless score.nil?
        value = score[:average]
        if Metrics::NORMALIZE.include?(metric)
          value = Metrics::normalize(metric, [value]).first
        end
      else
        value = 0.0
      end

      sum + value
    end
    sum / metrics.length
  end

  def record(i)
    instance_variable_get("@record#{i + 1}")
  end

end
