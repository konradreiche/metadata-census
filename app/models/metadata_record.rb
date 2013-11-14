class MetadataRecord
  include Mongoid::Document

  validates_presence_of :record
  belongs_to :snapshot

  field :record, type: Hash
  field :score, type: Float

  field :statistics, type: Hash

  Metrics::Metric.all.each do |metric|
    field metric, type: Hash
  end

  index({ 'snapshot_id' => 1 })
  index({ 'snapshot_id' => 1, 'statistics.resources' => 1 })

  ##
  # 
  #
  def calculate_score
    scores = Metrics::Metric.all.map { |m| send(m).maybe['score'] }.compact
    scores.sum.fdiv(scores.length)
  end

end
