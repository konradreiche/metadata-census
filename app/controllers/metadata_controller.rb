class MetadataController < ApplicationController

  def select
    begin
      preprocess
      gon.sample = @selected.sample
    rescue Tire::Search::SearchRequestFailed
      @repositories = []
    end
  end

  def search
    repository = params[:repository]
    q = params[:q]
    result = Tire.search('metadata') do
      query do
        boolean do
          must { string 'repository:' + repository }
          must { string q }
        end
      end
    end.results.map { |r| r.to_hash }
    render json: result
  end

  def preprocess
    @repositories = Repository.all
    if params[:repository].nil?
      @selected = @repositories.first if @selected.nil?
    else
      @selected = Repository.find params[:repository]
    end
    gon.repository = @selected.to_hash
  end

end
