class Metadatum

  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  def self.index
    Tire::Index.new('metadata')
  end

end
