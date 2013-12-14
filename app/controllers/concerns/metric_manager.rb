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
      gon.jbuilder 'app/views/jbuilder/metric.json.jbuilder'
    end
  end

  def metrics
    @metrics = Rails.cache.fetch('metrics') { Metrics::Metric.all }
    gon.jbuilder 'app/views/jbuilder/metrics.json.jbuilder'
  end

end
