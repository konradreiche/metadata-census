class Repository
  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  validates_presence_of :url, :type

  property :url
  property :type
end
