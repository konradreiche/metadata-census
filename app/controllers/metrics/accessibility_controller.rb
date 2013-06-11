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
      gon.grouped_accessibility = group_by(field)
    else
      field = 'groups'
      gon.grouped_accessibility = group_by(field)
    end
  end

  def group_by(field)
    accessors = field.split(/\./)
    grouped = Hash.new { |h, k| h[k] = [] }
    for record in @repository.metadata_with_field(field)
      group = accessors.inject(record) { |group, a| group[a.to_sym] }
      if group.is_a? Array
        group.each { |g| grouped[g] << record[:accessibility]}
      else
        grouped[group] << record[:accessibility]
      end
    end
    grouped.each { |portal, scores| grouped[portal] = scores.inject(:+)/scores.length }
  end

end
