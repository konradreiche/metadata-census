module Concerns::Metric

  def load_metrics(parameter=nil)
    unless parameter.nil?
      @metric = params[parameter].to_sym || Metrics.list.first
    end
    @metrics = Metrics.list

    gon.metric = @metric
    gon.metrics = @metrics
  end

end
