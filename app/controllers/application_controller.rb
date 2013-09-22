class ApplicationController < ActionController::Base
  rescue_from Exceptions::RepositoryNoScores, with: :repository_no_scores

  protect_from_forgery
  helper_method :all

end
