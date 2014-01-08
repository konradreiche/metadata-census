# A snapshot is a collection of metadata recordsa associated with one
# repository.
# 
# @author Konrad Reiche
#
class Snapshot
  include Mongoid::Document

  validates_presence_of :date
  has_many :metadata_records, :dependent => :destroy

  embedded_in :repository

  field :date, type: Date
  field :statistics, type: Hash

  Metrics::Metric.all.each do |metric|
    field metric.id, type: Hash
  end

  def best_records(metric)
    field = :"#{metric}.score"
    metadata_records.all.sort(field => -1).limit(10)
  end

  def worst_records(metric)
    field = :"#{metric}.score"
    metadata_records.all.sort(field => -1).limit(10)
  end

  def best_record(metric)
    field = :"#{metric}.score"
    metadata_records.all.sort(field => 1).first
  end

  def worst_record(metric)
    field = :"#{metric}.score"
    metadata_records.all.sort(field => 1).last
  end

  def score
    metrics = Metrics::Metric.all
    scores = metrics.map { |m| self.send(m.id).maybe['average'] }.compact

    return nil if scores.empty?
    scores.sum.fdiv(scores.length)
  end

  def <=>(other)
    self.date <=> other.date
  end

  def to_param
    date
  end

  def to_s
    date.to_s
  end

end
