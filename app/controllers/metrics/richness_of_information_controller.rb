class Metrics::RichnessOfInformationController < ApplicationController

  helper MetricsHelper
  helper_method :field_value, :resource_field_value, :link_for_record

  def details
    @repositories = Repository.all
    if params[:repository]
      @repository = Repository.find params[:repository]
    else
      @repository = @repositories.first
    end

    if params[:best]
      @best_record = @repository.get_record(params[:best])
    else
      @best_record = @repository.best_record('richness_of_information')
    end
    
    if params[:worst]
      @worst_record = @repository.get_record(params[:worst])
    else
      @worst_record = @repository.worst_record('richness_of_information')
    end

    @max_resources = [@best_record.fetch(:resources, []).length,
                      @worst_record.fetch(:resources, []).length].max
  end

  private
  def field_value(metadata, field)
    record = metadata[:record]
    if record.has_key?(field)
      record[field]
    else
      ''
      end
  end

  def resource_field_value(metadat, field, i)
    record = metadata[:record]
    resources = record[:resources]
    if not resources[i].nil? and resources[i].has_key?(field)
      resources[i][field]
    else
      ''
    end
  end


end
