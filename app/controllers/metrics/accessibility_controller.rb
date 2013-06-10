class Metrics::AccessibilityController < ApplicationController

  def details
    @repositories = Repository.all
    if params[:repository]
      @repository = Repository.find params[:repository]
    else
      @repository = @repositories.first
    end

    if @repository.id == 'GovData.de'
      gon.accessibility_by_portals = group_by_portal
    end
  end

  def group_by_portal
    field = 'extras.metadata_original_portal'
    grouped = Hash.new { |h, k| h[k] = [] }
    for record in @repository.metadata_with_field(field)
      grouped[record[:extras][:metadata_original_portal]] << record[:accessibility]
    end
    grouped.each { |portal, scores| grouped[portal] = scores.inject(:+)/scores.length }
  end

end
