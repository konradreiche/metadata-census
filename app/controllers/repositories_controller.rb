class RepositoriesController < ApplicationController
  include Concerns::Repository

  helper_method :metric_score

  def index
    load_all_repositories()
  end
  
  def show
    load_repositories(:repository)
    @score = @repository.score
    gon.score = @score
  end

  def leaderboard
    load_all_repositories()
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

  def metric_score(metric)
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
