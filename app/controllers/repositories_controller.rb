class RepositoriesController < ApplicationController

  def overview
    @repositories = Repository.all
    @active = "overview"
  end

  def map
    @repositories = Repository.all
    @active = "map"
  end

  def is_active?(page_name)
    "active" if params[:action] == page_name
  end

end
