module Concerns::Repository

  def load_repositories(parameter)
    @repositories = ::Repository.all
    @repository = params[parameter] || @repositories.first.name
    @repository = ::Repository.find(@repository)
    if @repository.nil? and params[parameter] == '*'
      @repository = Repository.new
      @repository.name = '*'
    end
    gon.repository = @repository.to_hash
  end

end
