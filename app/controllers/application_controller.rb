class ApplicationController < ActionController::Base
  rescue_from Exceptions::RepositoryNoScores, with: :repository_no_scores

  protect_from_forgery
  helper_method :all

  private

  def repository_no_scores
    render template: "errors/no_scores"
  end

end
