class RepositoriesController < ApplicationController
  include RepositoryManager
  include MetricManager

  helper_method :metric_score

  def index

    @numbers = Hash.new { |repository, numbers| repository[numbers] = {} }

    Repository.all.each do |repository|

      snapshot = repository.snapshots.last
      next if snapshot.nil?

      metadata = snapshot.metadata_records.only("record.resources")
      count = metadata.count

      numbers = metadata.map { |doc| doc["record"]["resources"].size }.sort

      metadata.min("record.resources")
      metadata.avg("record.resources")
      metadata.max("record.resources")
      metadata.sum("record.resources")

      @numbers[repository.id][:records] = count

      @numbers[repository.id][:minimum] = numbers.min
      @numbers[repository.id][:average] = numbers.reduce(:+).fdiv(count)
      @numbers[repository.id][:mean] = numbers[count / 2]
      @numbers[repository.id][:maximum] = numbers.max
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
