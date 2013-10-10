class MetadataRecord
  include Mongoid::Document

  validates_presence_of :record
  belongs_to :snapshot

  field :record, type: Hash
  field :score, type: Float

  field :statistics, type: Hash

  Metrics.all.each do |metric|
    field metric, type: Hash
  end

  index({ 'snapshot_id' => 1 })
  index({ 'statistics.resources' => 1 })

  ##
  # 
  #
  def calculate_score
    scores = Metrics.all.map { |m| (send(m).nil?) ? 0.0 : send(m)['score'] }
    scores.reduce(:+) / scores.length
  end

end
