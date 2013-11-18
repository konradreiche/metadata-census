class Repository
  include Mongoid::Document

  validates_presence_of :url, :type, :name
  embeds_many :snapshots, :order => :date.asc

  field :url
  field :type
  field :name

  field :latitude
  field :longitude

  index({ 'snapshots.date' => 1 })
  index({ 'snapshot.statistics.resources' => 1 })

  @@weighting = {}

  def self.update_weighting(weighting)
    @@weighting = weighting
  end

  ##
  # Returns a list of records sorted in descending by the score with respect to
  # the given metric.
  #
  def best_records(metric)
    sort_metric_scores(metric, 'desc').map { |entry| entry.to_hash }
  end

  def worst_records(metric)
    sort_metric_scores(metric, 'asc').map { |entry| entry.to_hash }
  end

  def best_record(metric)
    best_records(metric).first
  end

  def worst_record(metric)
    worst_records(metric).first
  end

  def score
    snapshot = snapshots.last
    metrics = Metrics::Metric.all
    scores = metrics.map do |metric|
      score = snapshot.maybe(metric).maybe['average']
      score = score * @@weighting.fetch(metric, 1.0) unless score.nil?
    end.compact

    return nil if scores.empty?

    if @@weighting.empty?
      max = scores.length
    else
      max = @@weighting.values.reduce(:+)
    end

    scores.reduce(:+).fdiv(max)
  end

  def <=>(other)
    self.score.to_f <=> other.score.to_f
  end

  def self.ranking(repositories)
    sorted = a.sort.uniq.reverse
    a.map {|e| sorted.index(e) + 1}
  end

  def display_name
    id
  end

end
