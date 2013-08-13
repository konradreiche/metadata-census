class ReportController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric
  include Report::Metric

  helper_method :metric_score, :record, :metric_abbreviation

  def repository
    load_repositories(:show)
    @score = @repository.score
  end

  def metric
    load_repositories(:repository)
    load_metrics(:show)
    load_records
    report(@metric, @repository)
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

  def record(i)
    instance_variable_get("@record#{i + 1}")
  end

  def metric_abbreviation(metric)
    metric.to_s.split('_').inject('') do |abbreviation, word|
      abbreviation + word.first
    end.upcase
  end

  def link_checker

  end

end
