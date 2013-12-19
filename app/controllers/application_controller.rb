class ApplicationController < ActionController::Base
  rescue_from Exceptions::RepositoryNoScores, with: :repository_no_scores
end
