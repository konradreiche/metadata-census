class AdminController < ApplicationController
  include RepositoryManager

  def scheduler
    redirect_to controller: "admin/repositories", action: "scheduler", repository_id: @repositories.first
  end

end
