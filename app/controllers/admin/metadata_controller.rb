class Admin::MetadataController < ApplicationController

  def create
    file = params[:file]
    id = params[:repository_id]
    repository = Repository.find(id)


    render nothing: true
  end

end
