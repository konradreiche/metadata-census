class RepositoriesController < ApplicationController
  include RepositoryManager
  include MetricManager

  helper_method :metric_score

  def index
    @numbers = Hash.new
    @languages = Set.new

    Repository.all.each do |repository|
      snapshot = repository.snapshots.last
      next if snapshot.nil? or snapshot.statistics.nil?

      @numbers[repository] = snapshot.statistics

      languages = @numbers[repository]['languages']
      @languages = @languages + languages.keys

      total = languages.values.sum
      languages.update(languages) { |language, count| count.fdiv(total) }
    end

    @languages.delete('Unknown').delete('Unreliable')
  end
  
  def show
    @score = @repository.score
    gon.score = @score
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

  def leaderboard
    @repositories.to_a.sort! { |x, y| x.score <=> y.score }
  end

  def map
    @repositories = Repository.all
    gon.repositories = @repositories.map { |r| r.attributes }
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

end
