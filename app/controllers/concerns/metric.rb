module Concerns::Metric

  def load_metrics(parameter)
    @metric = params[parameter].underscore.to_sym || Metrics.list.first.name
    @metrics = Metrics.list.map { |metric| metric.to_sym }
    gon.metric = @metric
    gon.metrics = @metrics
  end

end
