class RepositoriesController < ApplicationController
  def overview
    @repositories = Repository.all
  end
end
