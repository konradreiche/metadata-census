require 'sidekiq/testing/inline' if ENV['DEBUG']

class MetricsController < ApplicationController
  include RepositoryManager
  include MetadataRecordManager
  include AnalysisManager

  helper_method :metric_score, :record, :select_partial

  def overview
  end

  def show
    score = @snapshot.send(@metric.id)
    return render 'errors/no_results' if score.nil?

    @score = score['average']
    gon.score = @score
  end

  def distribution
    analyzer = Analyzer::QualityDistribution.new
    distribution = Rails.cache.fetch("#{@snapshot.date}#{@metric.id}") do
      analyzer.distribution(@snapshot, @metric)
    end
    render json: distribution
  end

  ##
  # Selects the partial for displaying the metric report.
  #
  # The selection is done based on the current metric. Either there is a
  # specific partial or a generic partial is returned as fallback.
  #
  def select_partial
    partials = "metrics/partials"
    directory = "app/views/" + partials

    ancestors = Metrics.from_sym(@metric).ancestors
    ancestors = ancestors.select { |cls| cls < Metrics::Metric }
 
    ancestors.map { |cls| cls.to_s.demodulize.underscore }.each do |candidate|
      file = "#{directory}/_#{candidate}.html.erb"
      return "#{partials}/#{candidate}" if File.exists?(file)
    end

    "metrics/partials/generic"
  end

end
