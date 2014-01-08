class AdminController < ApplicationController
  include RepositoryManager

  def scheduler
    repository = Repository.where(:snapshots.exists => true).first
    snapshot = repository.maybe.snapshots.maybe.last

    return render 'errors/no_snapshots' if snapshot.nil?

    path = { controller: "admin/snapshots",
             action: "scheduler",
             repository_id: repository.id,
             snapshot_date: snapshot.date }

    redirect_to path
  end

end
