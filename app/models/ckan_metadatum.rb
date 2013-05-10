class CkanMetadatum < Metadatum

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

  property :version
  property :state
  property :revision_id
  property :license
  property :isopen
  property :ratings_average
  property :ratings_count
  property :ckan_url
  
  property :relationships
  property :metadata_modified
  property :metadata_created
  property :notes_rendered
  property :tracking_summary
  property :repository


  def self.document_type
    'ckan'
  end

end
