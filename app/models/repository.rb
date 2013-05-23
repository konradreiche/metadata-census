class Repository

  include Tire::Model::Persistence
  include Tire::Model::Search
  include Tire::Model::Callbacks

  validates_presence_of :name, :type, :url, :datasets, :latitude, :longitude

  property :name
  property :type
  property :url
  property :latitude
  property :longitude
  property :datasets

  property :completeness
  property :weighted_completeness
  property :richness_of_information
  property :accuracy
  property :accessibility


  def metadata
    total = Tire.search('metadata', :search_type => 'count') do
      query { all }
    end.results.total

    name = @name
    Tire.search 'metadata' do
      query { string 'repository:' + name }
      size total
    end.results
  end

  def update_score(metric, score)
    self.send("#{metric.name}=", score)
  end

end
