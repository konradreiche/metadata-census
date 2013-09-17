class RepositoriesController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  before_filter :init, except: [:index]
  helper_method :metric_score

  ## 
  # Load additional resources
  #
  def init
    load_repositories(:repository)
    load_metrics()
  end

  def index
    load_all_repositories()
    require 'pry'; binding.pry
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
    begin
      @repositories = Repository.all
      gon.repositories = @repositories.map { |r| r.attributes }
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
  end

  def metric_score(metric, weighting=1.0)
    value = @repository.send(metric) if @repository.respond_to?(metric)
    unless value.nil?
      value = value[:average]
      value = Metrics::normalize(metric, [value]).first
      '%.2f%' % (value  * 100)
    else
      '-'
    end
  end

end
