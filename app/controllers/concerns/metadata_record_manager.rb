module MetadataRecordManager
  extend ActiveSupport::Concern

  include RepositoryManager
  include MetricManager

  included do
    before_filter :records
  end

  private
  def records

    if params[:documents].nil?
      @documents = [@snapshot.best_record(@metric.id),
                    @snapshot.worst_record(@metric.id)]
    else
      @documents = params[:documents].map do |id|
        MetadataRecord.find(id)
      end
    end
    gon.documents = @documents
  end

end
