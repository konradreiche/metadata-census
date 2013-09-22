module Concerns::Repository

  def load_repositories(parameter=nil)
    load_all_repositories()
    @repository = params[parameter] || @repositories.first.name
    @repository = ::Repository.find(@repository)
    gon.repository = @repository
  end

  def load_all_repositories
    @repositories = ::Repository.all.to_a
    gon.repositories = @repositories
  end

end
