module MetadataRecords
  extend ActiveSupport::Concern

  included do
    before_filter :records
  end

  private
  def records

    if params[:documents].nil?
      ss = @repository.snapshots.last
      @documents = [ss.best_record(@metric), ss.worst_record(@metric)]
    else
      @documents = params[:documents].map { |id| MetadataRecord.find(id) }
    end

    gon.documents = @document
  end

end
