class ReportController < ApplicationController

  def repository
    @repositories = Repository.all
    @repository = params[:show] || @repositories.first.name
    @repository = Repository.find(@repository)
    @score = average_score(@repository)
  end

  def average_score(repository)
    metrics = Metrics::IDENTIFIER
    sum = metrics.inject(0.0) do |sum, metric|
      score = repository.send(metric)
      unless score.nil?
        value = score[:average]
        if Metrics::NORMALIZE.include?(metric)
          value = Metrics::normalize(metric, [value]).first
        end
      else
        value = 0.0
      end

      sum + value
    end
    sum / metrics.length
  end

end
