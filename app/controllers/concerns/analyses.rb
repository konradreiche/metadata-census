module Analyses
  extend ActiveSupport::Concern

  included do
    before_filter :analyze
  end

  private
  def analyze
    specific = @metric.to_s.camelcase
    analyzer = "Analyzer::#{specific}".constantize

    @analysis = analyzer.analyze(@repository, @metric)
    gon.analysis = @analysis
  rescue NameError
    analyzer = Analyzer::Generic
    @analysis = analyzer.analyze(@repository, @metric)
    gon.analysis = @analysis
  end

end
