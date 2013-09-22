class MetadataRecord
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :record

  field :record, type: Hash

  belongs_to :snapshot

end
