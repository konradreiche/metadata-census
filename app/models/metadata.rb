class Metadata

  def initialize(attributes, repository, date, type)
    @attributes = Hash.new
    @attributes[:record] = attributes.to_json()
    @attributes[:date] = date
    @attributes[:type] = type
    @attributes[:repository] = repository
  end

  def to_indexed_json
    @attributes.to_json()
  end

end
