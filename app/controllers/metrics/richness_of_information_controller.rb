class Metrics::RichnessOfInformationController < ApplicationController

  helper_method :resource_description

  def details
    @repositories = Repository.all
    if params[:repository]
      @repository = Repository.find params[:repository]
    else
      @repository = @repositories.first
    end
    
    @best_record = @repository.best_record('richness_of_information')
    @worst_record = @repository.worst_record('richness_of_information')
    @max_resources = [@best_record[:resources].length,
                      @worst_record[:resources].length].max
  end

  private
  def resource_description(record, i)
    resources = record[:resources]
    if not resources[i].nil? and resources[i].has_key?(:description)
      resources[i][:description]
    else
      ''
    end
  end

end
