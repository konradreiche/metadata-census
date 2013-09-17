class Metadata
  include Tire::Model::Callbacks
  include Tire::Model::Persistence
  include Tire::Model::Search

  def initialize(record, type, repository, date)
    @type = type
    @attributes = Hash.new

    @attributes[:record] = record.to_json()
    @attributes[:repository] = repository
    @attributes[:date] = date
  end

  def to_indexed_json
    @attributes.to_json()
  end
  
  def document_type
    @type
  end

end
