class RepositoriesController < ApplicationController

  def overview
    @repositories = Repository.all
  end

  def map
    @repositories = Repository.all
  end

end
