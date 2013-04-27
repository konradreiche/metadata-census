class RepositoriesController < ApplicationController

  def overview
    @repositories = Repository.all
  end

  def map
    @repositories = Repository.all
    gon.repositories = @repositories.map { |r| r.attributes }
  end

end
