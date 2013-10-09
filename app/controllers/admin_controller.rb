class AdminController < ApplicationController
  include RepositoryManager

  def scheduler
    repository = Repository.where(:snapshots.exists => true).first
    snapshot = repository.snapshots.last

    path = { controller: "admin/snapshots",
             action: "scheduler",
             repository_id: repository.id,
             snapshot_id: snapshot.id }

    redirect_to path
  end

end
