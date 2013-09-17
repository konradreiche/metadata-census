class Metadata
  include Mongoid::Document

  validates_presence_of :record, :repository, :date, :type

  field :record
  field :repository
  field :date
  field :type

  belongs_to :repository

end
