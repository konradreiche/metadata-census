class RepositoriesController < ApplicationController
  include Concerns::Repository

  def overview
    load_all_repositories()
  end

  def leaderboard
    load_all_repositories()
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
