module Concerns::Metric

  def load_metrics(parameter)
    @metric = params[parameter].underscore.to_sym || Metrics.list.first.name
    gon.metric = @metric
    gon.metrics = Metrics.list.map { |metric| metric.to_sym }
  end

end
