class Repository

  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  validates_presence_of :name, :type, :url, :latitude, :longitude

  property :name
  property :type
  property :url
  property :latitude
  property :longitude

  property :completeness
  property :weighted_completeness
  property :richness_of_information
end
