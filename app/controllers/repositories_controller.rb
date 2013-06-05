class RepositoriesController < ApplicationController

  def overview
    begin
      @repositories = Repository.all
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
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
