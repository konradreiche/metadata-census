class AdminController < ApplicationController
  include Concerns::Repository

  def scheduler
    load_repositories()
    redirect_to controller: "admin/repositories", action: "scheduler", repository_id: @repository
  end

end
