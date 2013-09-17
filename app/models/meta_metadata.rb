class MetaMetadata
  include Mongoid::Document

  validates_presence_of :record, :repository, :date, :type, :count

  field :record
  field :repository
  field :date
  field :type
  field :count

end
