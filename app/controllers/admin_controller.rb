class AdminController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  def scheduler
    redirect_to controller: "admin/repositories", action: "scheduler", repository_id: "data.gov.uk"
  end

end
