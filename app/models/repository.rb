class Repository
  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  validates_presence_of :name, :type, :url, :_id

  property :name
  property :type
  property :url
  property :_id
end
