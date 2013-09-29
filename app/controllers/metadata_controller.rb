class MetadataController < ApplicationController
  include RepositoryManager

  def search
    query = params[:term]
    snapshot = @repository.snapshots.last
    
    criteria = { :"record.title" => /#{query}.*/ }
    query = MetadataRecord.where(snapshot: snapshot).any_of(criteria).limit(10)
    render json: query.all
  end

  def normalize
    metric = params[:metric]
    score = Float(params[:score])
    
    normalized = Metrics.normalize(metric, score)
    render text: normalized
  end

end
