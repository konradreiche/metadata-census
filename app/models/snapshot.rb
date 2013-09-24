require 'digest'

class Snapshot
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :date

  has_many :metadata_records

  field :_id, default: -> { Digest::MD5.hexdigest("#{date}#{repository}") }

  field :date, type: Date

  field :repository

  Metrics::list.each do |metric|
    field metric, type: Hash
  end

  belongs_to :repository
 
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

  def query(metric, group=nil)
    field = :"#{metric}.score"
    metadata_records.only(field, group).all
  end

end
