require 'digest'

class MetadataRecord
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :record

  field :record, type: Hash

  Metrics.all.each do |metric|
    field metric, type: Hash
  end

  belongs_to :snapshot

end
