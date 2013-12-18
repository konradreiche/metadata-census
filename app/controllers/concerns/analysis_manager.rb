module AnalysisManager
  extend ActiveSupport::Concern

  include RepositoryManager
  include MetricManager

  included do
    before_filter :analyze
  end

  ANALYZER_PATH = 'app/models/analyzer'

  private
  def analyze
    metric = @metric.to_s.underscore
    file = "#{ANALYZER_PATH}/#{metric}.rb"

    if File.exists?(file)
      analyzer = "Analyzer::#{metric.camelcase}".constantize
    else
      analyzer = Analyzer::Generic
    end

    @analysis = analyzer.analyze(@snapshot, @metric)
    gon.analysis = @analysis
  end

end
