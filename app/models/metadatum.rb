class Metadatum
  include Tire::Model::Persistence

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
end
