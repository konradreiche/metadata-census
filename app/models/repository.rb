class Repository
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :id, :name, :url, :type, :latitude, :longitude

  has_many :metadata

  field :id
  field :name
  field :type
  field :url
  field :latitude
  field :longitude
  field :datasets
  field :score

  Metrics::list.each do |metric|
    field metric, type: Hash
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

  def document(id)
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

  ##
  # Updates this repository based on a given repository hash.
  #
  def update(repository)
    self.class.properties.each do |property|
      value = repository[property]
      self.send("#{property}=", value) unless value.nil?
    end
    self.update_index
  end

  def update_score(metric, score)
    self.send("#{metric.name}=", score)
  end

  ##
  # Returns a list of records sorted in descending by the score with respect to
  # the given metric.
  #
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

  def score(weighting={})
    metrics = Metrics.list
    sum = metrics.inject(0.0) do |sum, metric|
      score = self.send(metric)
      unless score.nil?
        score = score.with_indifferent_access
        value = score[:average]
        if Metrics.from_sym(metric).normalize?
          value = Metrics::normalize(metric, [value]).first
        end
      else
        value = 0.0
      end
      sum + (value * weighting.fetch(metric, 1.0))
    end
    sum / metrics.length
  end

  def <=>(other)
    self.score <=> other.score
  end

  def query(*fields)
    repository = @name
    Tire::Search::Scan.new('metadata') do
      query { string "repository:#{repository}" }
      fields fields
    end.map { |scroll| scroll.map(&:to_hash) }.flatten
  end

end
