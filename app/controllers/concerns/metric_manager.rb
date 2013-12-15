module MetricManager
  extend ActiveSupport::Concern

  included do
    before_filter :metric, :metrics
  end

  private
  def metric
    id = params[:metric_id] || params[:id]

    unless id.nil?
      metrics = Metrics::Metric.all
      index = metrics.map(&:id).index(id)
      unless index.nil?
        @metric = metrics[index]
        jbuilder __method__
      end
    end
  end

  def metrics
    @metrics = Rails.cache.fetch('metrics') { Metrics::Metric.all }
    jbuilder __method__
  end

end
