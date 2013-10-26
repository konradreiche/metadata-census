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

  Metrics.all.each do |metric|
    field metric, type: Hash
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

  def <=>(other)
    self.date <=> other.date
  end

  def display_name
    date.to_s
  end

end
