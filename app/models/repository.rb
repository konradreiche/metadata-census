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
    name = @name
    max = total
    Tire.search 'metadata' do
      query { string 'repository:' + name }
      size max
    end.results.map { |entry| entry.to_hash }
  end

  def sample
    name = @name
    Tire.search 'metadata' do
      query { string 'repository:' + name }
    end.results.map { |entry| entry.to_hash }.sample
  end

  def total
    name = @name
    total = Tire.search('metadata', :search_type => 'count') do
      query { string 'repository:' + name }
    end.results.total
  end

  def metadata_with_field(field, value="*")
    name = @name
    max = total
    Tire.search 'metadata' do
      query do
        boolean do
          must { string 'repository:' + name }
          must { string field + ":" + value }
        end
      end
      size max
    end.results.map { |entry| entry.to_hash }
  end

  def update_score(metric, score)
    self.send("#{metric.name}=", score)
  end

  def best_record(metric)
    sort_metric_scores(metric, 'desc').first.to_hash
  end

  def worst_record(metric)
    sort_metric_scores(metric, 'asc').first.to_hash
  end

  private
  def sort_metric_scores(metric, sorting_order)
    name = @name
    search = Tire.search 'metadata' do
      query { string "repository:#{name}" }
      sort { by metric, sorting_order }
    end.results
  end

end
