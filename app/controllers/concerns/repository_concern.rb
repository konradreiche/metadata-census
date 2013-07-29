module RepositoryConcern

  def load(parameter)
    @repositories = Repository.all
    @repository = params[parameter] || @repositories.first.name
    @repository = Repository.find(@repository)
  end

end
