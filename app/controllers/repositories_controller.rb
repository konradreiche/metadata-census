class RepositoriesController < ApplicationController

  def overview
    @repositories = Repository.all
  end

  def map
    @repositories = Repository.all
    gon.repositories = @repositories
  end

  def is_active?(page_name)
    "active" if params[:action] == page_name
  end

end
