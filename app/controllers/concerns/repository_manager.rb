module RepositoryManager
  extend ActiveSupport::Concern

  included do
    before_filter :repository, :snapshot, :repositories
  end

  def repository
    id = params[:repository_id] || params[:id]

    if id.nil?
      @repository = Repository.all.first
    else
      @repository = Repository.find(id)
    end

    gon.repository = @repository
  end

  def snapshot
    date = params[:snapshot_id] || params[:id]

    if not params[:repository_id].nil? and not date.nil?
      @snapshot = @repository.snapshots.where(date: date).first
    end
  end

  def repositories
    @repositories = Repository.all.to_a
    gon.repositories = @repositories
  end

end
