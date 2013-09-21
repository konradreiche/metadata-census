class Metadata
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :record

  field :record, type: Hash

end
