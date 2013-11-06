class ApplicationController < ActionController::Base
  rescue_from Exceptions::RepositoryNoScores, with: :repository_no_scores

  protect_from_forgery
  helper_method :all

  private
  def forge_parameters(repository, snapshot=nil, metric=nil)
    if snapshot.nil? and metric.nil?
      { id: repository.id }
    elsif metric.nil?
      { repository_id: repository.id, id: snapshot.date.to_s }
    else
      date = snapshot.date.to_s
      { repository_id: repository.id, snapshot_id: date, id: metric }
    end
  end

end
