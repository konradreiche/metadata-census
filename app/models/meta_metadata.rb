class MetaMetadata
  include Mongoid::Document

  validates_presence_of :metadata, :repository, :date, :type

  field :metadata
  field :repository
  field :date
  field :type

end
