class Metrics::AccessibilityController < ApplicationController

  def details
    @repositories = Repository.all
    if params[:repository]
      @repository = Repository.find params[:repository]
    else
      @repository = @repositories.first
    end

    if @repository.id == 'GovData.de'
      field = 'extras.metadata_original_portal'
      gon.grouped_accessibility = normalize(@repository, field)
    else
      field = 'groups'
      gon.grouped_accessibility = normalize(@repository, field)
    end
  end

  def normalize(repository, field)
    metadata = repository.metadata_with_field(field)
    values = metadata.map { |record| record[:accessibility] }
    max = values.max
    min = values.min
    range = max - min

    accessors = field.split(/\./)
    grouped = Hash.new { |h, k| h[k] = [] }
    metadata.each do |record|
      group = accessors.inject(record) { |group, a| group[a.to_sym] }
      # if there is more than one group
      value = 100 * (record[:accessibility] - min) / range
      if group.is_a? Array
        group.each { |g| grouped[g] << value }
      else
        grouped[group] << value
      end
    end

    grouped.each do |portal, scores|
      grouped[portal] = scores.inject(:+) / scores.length
    end

    thin_out(grouped)
  end

  def thin_out(grouped)
    values = []
    grouped.delete_if do |key|
      range = grouped[key].to_i
      if values.include?(range)
        true
      else
        values << range
        false
      end
    end
    grouped
  end
  
end
