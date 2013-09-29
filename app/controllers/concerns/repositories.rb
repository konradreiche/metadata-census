module Repositories
  extend ActiveSupport::Concern

  included do
    before_filter :repository, :repositories
  end

  def repository
    id = params[:repository_id] || params[:id]

    unless id.nil?
      @repository = ::Repository.find(id)
      gon.repository = @repository
    end
  end

  def repositories
    @repositories = ::Repository.all
    gon.repositories = @repositories
  end

end
