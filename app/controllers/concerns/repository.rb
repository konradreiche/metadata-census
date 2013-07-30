module Concerns::Repository

  def load_repositories(parameter)
    @repositories = ::Repository.all
    @repository = params[parameter] || @repositories.first.name
    @repository = ::Repository.find(@repository)
    gon.repository = @repository.to_hash
  end

end
