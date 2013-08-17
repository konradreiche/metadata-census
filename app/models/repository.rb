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
  property :score

  Metrics::list.each do |metric|
    property metric
  end

  def metadata
    name = @name
    max = total / 4
    results = Tire::Search::Scan.new('metadata') do
      query { string 'repository:' + name }
      size max
    end.results
    results.map { |entry| entry.to_hash }
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

  def get_record(id)
    metadata_with_field(:_id, id).first
  end

  def metadata_with_field(field, value="*")
    name = @name
    max = total
    Tire.search 'metadata' do
      query do
        boolean do
          must { string 'repository:' + name }
          must { string field.to_s + ":" + value }
        end
      end
      size max
    end.results.map { |entry| entry.to_hash }
  end

  def update_score(metric, score)
    self.send("#{metric.name}=", score)
  end

  def best_records(metric)
    records = sort_metric_scores(metric, 'desc').map { |entry| entry.to_hash }
  end

  def worst_records(metric)
    records = sort_metric_scores(metric, 'asc').map { |entry| entry.to_hash }
  end

  def best_record(metric)
    best_records(metric).first
  end

  def worst_record(metric)
    worst_records(metric).first
  end

  def sort_metric_scores(metric, sorting_order, many=10)
    name = @name
    metric = :"#{metric}.score"
    search = Tire.search 'metadata' do
      query { string "repository:#{name}" }
      sort { by metric, sorting_order }
      size many
    end.results
  rescue Tire::Search::SearchRequestFailed => e
    Rails.logger.warn e.message
    raise Exceptions::RepositoryNoScores
  end

  def score
    metrics = Metrics::IDENTIFIERS
    sum = metrics.inject(0.0) do |sum, metric|
      score = self.send(metric)
      unless score.nil?
        value = score[:average]
        if Metrics::NORMALIZE.include?(metric)
          value = Metrics::normalize(metric, [value]).first
        end
      else
        value = 0.0
      end
      sum + value
    end
    sum / metrics.length
  end

end
