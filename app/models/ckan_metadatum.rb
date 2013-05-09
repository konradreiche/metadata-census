class CkanMetadatum

  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  property :name
  property :title
  property :author
  property :author_email
  property :maintainer
  property :maintainer_email
  property :notes
  property :groups
  property :tags
  property :url
  property :type
  property :resources
  property :license_id
  property :extras

  property :completeness
  property :weighted_completeness
  property :richness_of_information
  property :accuracy

  def _type
    'ckan'
  end

  def _index
    'metadata'
  end

end
