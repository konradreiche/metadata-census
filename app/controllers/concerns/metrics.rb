module Metrics
  extend ActiveSupport::Concern

  included do
    before_filter :metric, :metrics
  end

  private
  def metrics
    @metric = (params[:metric_id] || params[:id]).to_sym
    gon.metric = @metric
  end

  def metrics
    @metrics = Metrics.all
    gon.metrics = @metrics
  end

end
