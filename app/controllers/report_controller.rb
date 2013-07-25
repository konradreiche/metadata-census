class ReportController < ApplicationController

  def repository
    @repositories = Repository.all
    @repository = params[:repository] || @repositories.first.name
    @repository = Repository.find(@repository)
  end

end
