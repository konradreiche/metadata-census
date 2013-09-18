module Concerns::Repository

  def load_repositories(parameter=nil)
    load_all_repositories()
    @repository = params[parameter] || @repositories.first.name
    @repository = ::Repository.find(@repository)
    if @repository.nil? and params[parameter] == 'All'
      @repository = Repository.new
      @repository.name = 'All'
    end
    gon.repository = @repository
  end

  def load_all_repositories
    begin
      @repositories = ::Repository.all.to_a
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
    gon.repositories = @repositories
  end

end
