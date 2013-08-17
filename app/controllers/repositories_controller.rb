class RepositoriesController < ApplicationController
  include Concerns::Repository

  def index
    load_all_repositories()
  end
  
  def show
    load_repositories(:repository)
    @score = @repository.score
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

end
