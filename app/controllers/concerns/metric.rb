module Concerns::Metric

  def load_metrics(parameter=nil)
    unless parameter.nil?
      metric = params[parameter]
      @metric = metric.underscore.dasherize.to_sym || Metrics.list.first.name
    end
    @metrics = Metrics.list.map { |metric| metric.to_sym }
    gon.metric = @metric
    gon.metrics = @metrics
  end

end
