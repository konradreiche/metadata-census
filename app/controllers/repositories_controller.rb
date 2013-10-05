class RepositoriesController < ApplicationController
  include RepositoryManager
  include MetricManager

  helper_method :metric_score

  def index
    @numbers = Hash.new { |repository, metric| repository[metric] = Hash.new }
    Repository.all.each do |repository|
      snapshot = repository.snapshots.last
      next if snapshot.nil?

      criteria = MetadataRecord.where(snapshot: snapshot)
      @numbers[repository][:min] = criteria.min("statistics.resources")
      @numbers[repository][:avg] = criteria.avg("statistics.resources")
      @numbers[repository][:max] = criteria.max("statistics.resources")
      @numbers[repository][:sum] = criteria.sum("statistics.resources")
    end
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
