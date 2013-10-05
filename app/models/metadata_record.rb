require 'digest'

class MetadataRecord
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :record
  belongs_to :snapshot

  field :record, type: Hash

  Metrics.all.each do |metric|
    field metric, type: Hash
  end

end
