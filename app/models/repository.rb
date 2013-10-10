class Repository
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :url, :type, :name
  embeds_many :snapshots, :order => :date.asc

  field :url
  field :type
  field :name

  field :latitude
  field :longitude

  index({ 'snapshots.date' => 1 })

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

  def score(weighting={})
    metrics = Metrics.all

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

  def <=>(other)
    self.score <=> other.score
  end

  def self.ranking(repositories)
    sorted = a.sort.uniq.reverse
    a.map{|e| sorted.index(e) + 1}
  end

  def display_name
    id
  end

end
