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
    
    @worst_record = @repository.worst_record('richness_of_information')
    @max_resources = [@best_record.fetch(:resources, []).length,
                      @worst_record.fetch(:resources, []).length].max
  end

  private
  def field_value(record, field)
    if record.has_key?(field)
      if record[field].is_a?(Array)
        record[field].join(", ")
      else
        record[field]
      end
    else
      ''
      end
  end

  def resource_field_value(record, field, i)
    resources = record[:resources]
    if not resources[i].nil? and resources[i].has_key?(field)
      resources[i][field]
    else
      ''
    end
  end

  def link_for_record(record)
    link = 'richness-of-information'
    link = link + '?repository=' + @repository.name
    link = link + '&best=' + record[:id]
    link
  end

end
