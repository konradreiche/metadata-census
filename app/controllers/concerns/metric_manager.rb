module MetricManager
  extend ActiveSupport::Concern

  included do
    before_filter :metric, :metrics
  end

  private
  def metric
    id = params[:metric_id] || params[:id]

    unless id.nil?
      @metric = id.to_sym
      gon.metric = @metric
    end
  end

  def metrics
    @metrics = Rails.cache.fetch('metrics') { Metrics::Metric.all }
    gon.metrics = @metrics
  end

end
