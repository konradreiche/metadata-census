module Concerns::Metric

  def load_metrics(parameter)
    @metric = params[parameter] || Metrics::IDENTIFIERS.first
    @metric = @metric.underscore if @metric.is_a?(String)
    @metric = @metric.to_sym
    gon.metric = @metric
    gon.metrics = Metrics::IDENTIFIERS
  end

end
