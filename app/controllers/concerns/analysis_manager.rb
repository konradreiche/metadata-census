module AnalysisManager
  extend ActiveSupport::Concern

  include RepositoryManager
  include MetricManager

  included do
    before_filter :analyze
  end

  private
  def analyze
    specific = @metric.to_s.underscore.camelcase
    analyzer = "Analyzer::#{specific}".constantize

    @analysis = analyzer.analyze(@snapshot, @metric)
    gon.analysis = @analysis
  rescue NameError => e
    Rails.logger.error(e)
    analyzer = Analyzer::Generic

    @analysis = analyzer.analyze(@snapshot, @metric)
    gon.analysis = @analysis
  end

end
