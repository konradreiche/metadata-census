class Metrics::AccessibilityController < ApplicationController

  def details
    @repositories = Repository.all
    if params[:repository]
      @repository = Repository.find params[:repository]
    else
      @repository = @repositories.first
    end
  end

end
