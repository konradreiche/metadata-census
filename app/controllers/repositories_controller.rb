class RepositoriesController < ApplicationController
  include RepositoryManager
  include MetricManager
  include Comparable

  helper_method :metric_score

  def index
    repositories = @repositories.keys

    @languages = Rails.cache.fetch('repository_languages') do
      repositories.each_with_object(Set.new) do |repository, result|
        statistics = @repositories[repository]['statistics'].to_h
        languages = statistics['languages'].to_h

        languages.update(languages) do |_, count| 
          count.fdiv(languages.values.sum)
        end
        result.merge(languages.keys)
      end
    end

    gon.scores = repositories.map do |repository|
      next if repository.snapshots.count <= 1
      data = repository.snapshots.map do |snapshot| 
        [snapshot.date.to_time.to_i * 1000, snapshot.score] 
      end
      { 'label' => repository.id, 'data'  => data }
    end.compact
  end

  # Multiply UNIX timestamp by 1000 to convert time into date
  def show
    gon.graph_data = @repository.snapshots.map do |snapshot| 
      [snapshot.date.to_time.to_i * 1000, snapshot.score]
    end
  end

  def score
    weighting = Hash.new
    @metrics.each do |metric|
      weighting[metric] = params[metric].to_i unless params[metric].nil?
    end
    render text: @repository.score(weighting)
  end

  def scores
    result = @metrics.each_with_object({}) do |metric, scores|
      scores[metric] = metric_score(metric)
    end
    render json: result
  end

  def metric_score(metric, weighting=1.0)
    snapshot = @repository.snapshots.last
    value = snapshot.maybe(metric)
    unless value.nil?
      value = value[:average]
      value = Metrics::normalize(metric, [value]).first
      '%.2f%' % (value  * 100)
    else
      '-'
    end
  end

  def statistics
    snapshot = @repository.snapshots.last
    @times = snapshot.statistics['times']
  end

  def weighting
    weighting = params[:weightings]
    weighting.each { |metric, weight| weighting[metric] = weight.to_i }

    session[:weightings] = weighting
    Repository.update_weighting(weighting)

    render nothing: true
  end

end
