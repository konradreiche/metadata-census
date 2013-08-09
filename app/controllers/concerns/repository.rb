module Concerns::Repository

  def load_repositories(parameter)
    load_all_repositories()
    @repository = params[parameter] || @repositories.first.name
    @repository = ::Repository.find(@repository)
    if @repository.nil? and params[parameter] == '*'
      @repository = Repository.new
      @repository.name = '*'
    end
    gon.repository = @repository.to_hash
  end

  def load_all_repositories
    begin
      @repositories = ::Repository.all
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
    gon.repositories = @repositories
  end

end
