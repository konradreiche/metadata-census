class Metadatum

  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  index_name 'metadata'

end
