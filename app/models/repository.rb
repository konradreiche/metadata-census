class Repository
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :id, :name, :url, :type, :latitude, :longitude

  has_many :snapshots, :order => :date.asc

  field :id
  field :name

  field :type
  field :url

  field :latitude
  field :longitude

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
  end

  def score(weighting={})
    metrics = Metrics.list
    sum = metrics.inject(0.0) do |sum, metric|
      score = snapshots.last.maybe(metric)
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

  def latest_snapshot
    snapshots.sort.last
  end

  def <=>(other)
    self.score <=> other.score
  end

end
